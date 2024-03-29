#INCLUDE "totvs.ch"
#INCLUDE "restFul.ch"
#include "protheus.ch" 
#include "tbiConn.ch" 
#include "topConn.ch" 
#include "tryException.ch"

/*
Programa.: WSFINAN.PRW 
Tipo.....: Webservice Rest 
Autor....: Odair Batista - TOTVS Unidade Londrina
Data.....: 27/02/2020
Descri��o: Webservice para consulta de fluxo financeiro  
Notas....:  
*/

#define str0001 "Servi�o de Consulta ao Fluxo Financeiro" 
#define str0002 "M�todo para Consulta do Fluxo Financeiro" 


/*/{Protheus.doc} WSFINAN
Servi�o para chamada externa
@author Odair Batista - TOTVS Unidade Londrina
@since 27/02/2020
@version 1.0
@type service
/*/
WsRestFul WSFINAN description str0001   
	WsData ClientID as String				//ID do ciente consumidor 
	WsData Company  as String				//C�digo da empresa 
	WsData Branch   as String optional		//C�digo da filial
	WsData Range    as String 				//Ano e m�s para processamento
	
	WsMethod Get description str0002 WsSyntax "/WSFINAN/{ClientID, Company, Branch, Range}"
End WsRestFul 


/*/{Protheus.doc} GetFluxo
M�todo para processamento da consulta
@author Odair Batista - TOTVS Unidade Londrina
@since 27/02/2020
@version 1.0
@type method
@param ClientID, caracter, ID do cliente consumidor
@param Company , caracter, C�digo da empresa
@param Branch  , caracter, C�digo da filial
@param Range   , caracter, Ano e m�s de processamento
/*/
WsMethod Get WSReceive ClientID, Company, Branch, Range WsService WSFINAN 
 	local oException := nil
 	local aAlerts    := {}
 	local nRow       := 0
	local hasErrors  := .f.
 	
	private oAlerts := nil
	private cXML    := ""
	
	private cCodMun := ""
  	private aRange  := array(2)	 

	default Self:ClientID := "?"
	default Self:Company  := "27"
	default Self:Branch   := "01"
	default Self:Range    := strZero(year(date()), 4) + strZero(month(date()), 2)

	rpcSetType(3)			                //Informa que n�o haver� consumo de licen�as
	rpcSetEnv(Self:Company, Self:Branch)	//Prepara ambiente para empresa 01 e filial 01

	//define o tipo de retorno do m�todo
	Self:SetContentType("application/xml")

	oAlerts := tcAlerts():New()
	oAlerts:Empty()

	if !oAlerts:HasErrors()
		dbSelectArea("ZAA")
		ZAA->(dbSetOrder(1))	//ZAA_ID+ZAA_CODEMP
			
		Self:ClientID := padR(Self:ClientID, len(ZAA->ZAA_ID), " ")
	
		//Verifica permiss�o de visualiza��o do cliente consumidor
		if Self:ClientID <> "ROOT-ADM-ANALYZER"
			if !ZAA->(dbSeek(Self:ClientID + Self:Company))
				oAlerts:Add("17002" ;
							, "Cliente sem permissao!" ;
							, "E" ;
							, "O cliente com ID [" + allTrim(Self:ClientID) + "] nao possui permissao de acesso " ;
							  + "a empresa [" + Self:Company + "]. Verifique!")
			elseIf ZAA->ZAA_DATINI > date() ;
				.or. ZAA->ZAA_DATFIM < date()
				
				oAlerts:Add("17003" ;
							, "Cliente sem permissao!" ;
							, "E" ;
							, "O cliente com ID [" + allTrim(Self:ClientID) + "] nao possui permissao de acesso " ;
							  + "a empresa [" + Self:Company + "] porque a data corrente esta fora do per�odo de validade. Verifique!")
			endIf
		endIf
		
		if !oAlerts:HasErrors()
			tryException
				tryException
					cCodMun   := superGetMV("MV_UCODMUN", .f., "", cFilAnt)
					aRange[1] := sToD(left(Self:Range, 4) + right(Self:Range, 2) + "01")	//Primeiro dia do m�s/ano solicitado
					aRange[2] := lastDay(aRange[1])											//�ltimo dia do m�s/ano solicitado
					
					openXML()
					doPutFluxo()
					closeXML()
	
					Self:SetResponse(cXML)
				catchException using oException
					addError(oException)
				endException
			catchException using oException
				addError(oException)
			endException
		endIf
	endIf

	if oAlerts:HasErrors()
		aAlerts := oAlerts:GetErrors()
	
		for nRow := 1 to len(aAlerts)
			SetRestFault(val(allTrim(aAlerts[nRow, 1])), allTrim(aAlerts[nRow, 4]))
		next nRow
	endIf

	hasErrors := oAlerts:GetAlerts()
	oAlerts:Destroy()

    rpcClearEnv() //volta a empresa anterior
return(!hasErrors)


/*/{Protheus.doc} addError
Fun��o para adcionar erro por exce��o
@author Odair Batista - TOTVS Unidade Londrina
@since 10/02/2020
@version 1.0
@type function
@param oException, objeto, Objeto da exce��o do erro
/*/
static function addError(oException)
	local cDesc := ""
	local cHelp := ""
	
	if valType(oException) <> "O"
		cDesc := "Erro indeterminado!"
		cHelp := "Um erro n�o determinado ocorreu."
	else
		cDesc := oException:Description
		cHelp := oException:ErrorStack
	endIf
	
	oAlerts:Add("WSFINAN" ;
				, cDesc ;
				, "E" ;
				, cHelp) 
return


/*/{Protheus.doc} openXML
Fun��o para abertura do XML
@author Odair Batista - TOTVS Unidade Londrina
@since 10/02/2020
@version 1.0
@type function
/*/
static function openXML()
	cXML := ''
	cXML += '<?xml version="1.0" encoding="ISO-8859-1"?>'
	cXML += '<root>'
return


/*/{Protheus.doc} closeXML
Fun��o para fechamento do XML
@author Odair Batista - TOTVS Unidade Londrina
@since 10/02/2020
@version 1.0
@type function
/*/
static function closeXML()
	cXML += '</root>'
return


/*/{Protheus.doc} putHeader
Fun��o para inputar dados do cabe�alho
@author Odair Batista - TOTVS Unidade Londrina
@since 27/02/2020
@version 1.0
@type function
@param cTitle, caracter, T�tulo para o cabe�alho
/*/
static function putHeader(cTitle)
	cXML += '<Cabecalho>'
	cXML += '<TipoDocumento>' + cTitle + '</TipoDocumento>'
	cXML += '<AnoExercicio>' + strZero(year(aRange[1]), 4) + '</AnoExercicio>'
	cXML += '<MesExercicio>' + mesExtenso(month(aRange[1])) + '</MesExercicio>'
	cXML += '<Municipio>' + cCodMun + '</Municipio>'
	cXML += '<DataCriacaoXML>' + strZero(year(date()), 4) + "-" + strZero(month(date()), 2) + "-" + strZero(day(date()), 2) + '</DataCriacaoXML>'
	cXML += '</Cabecalho>'
return


/*/{Protheus.doc} doPutFluxo
Fun��o para inputar dados do fluxo de caixa financeiro
@author Odair Batista - TOTVS Unidade Londrina
@since 27/02/2020
@version 1.0
@type function
/*/
static function doPutFluxo()
	local cQuery    := ""
	local cCodVisao := "003"
	local oTTres    := nil
	local oTTvis    := nil
	local cOrder    := ""
	local aStrRes   := {}
	local aStrFJ3   := {}
	local nRow      := 0
	local cTable    := ""
	local nProcQry  := 0
	local cInsert   := ""
	local cColuna   := ""
	local cSuperior := ""
	local cIdenti   := ""
	local nRecno    := 0

	//INICIO: Cria��o da tabela tempor�ria de retorno dos resultados
	aAdd(aStrRes, {"CTACODE"   , "C", 20, 0})
	aAdd(aStrRes, {"CTADESC"   , "C", 60, 0})
	aAdd(aStrRes, {"CODDESC"   , "C", 30, 0})
	aAdd(aStrRes, {"RECEBIDOS" , "N", 17, 2})
	aAdd(aStrRes, {"PAGOS"     , "N", 17, 2})
	aAdd(aStrRes, {"DATAAN"    , "D",  8, 2})
	aAdd(aStrRes, {"DISPONIVEL", "N", 17, 2})
	aAdd(aStrRes, {"DATAX"     , "D",  8, 0})
	aAdd(aStrRes, {"ORDEM"     , "C", 17, 2})

	if select("ttRes") > 0
		ttRes->(dbCloseArea())
	endIf
		    
	if oTTres <> nil
		oTTres:Delete()
		oTTres := nil
	endIf

	oTTres := fwTemporaryTable():New("ttRes")  
	oTTres:SetFields(aStrRes) 	
	oTTres:AddIndex("1", {"CTACODE"})				
	oTTres:Create()	

	ttRes->(dbSetOrder(1)) 
	//T�RMINO: Cria��o da tabela tempor�ria de retorno dos resultados

	//INICIO: Cria��o da tabela tempor�ria da vis�o gerencial financeira
	aAdd(aStrFJ3, {"FJ3_REC"   , "N", 16, 2})
	aAdd(aStrFJ3, {"FJ3_PAGO"  , "N", 16, 2})
	aAdd(aStrFJ3, {"FJ3_DISP"  , "N", 16, 2})
	aAdd(aStrFJ3, {"FJ3_FILIAL", "C", tamSX3("FJ3_FILIAL")[1], 0})
	aAdd(aStrFJ3, {"FJ3_CODPLA", "C", tamSX3("FJ3_CODPLA")[1], 0})
	aAdd(aStrFJ3, {"FJ3_ORDEM" , "C", tamSX3("FJ3_ORDEM")[1] , 0})
	aAdd(aStrFJ3, {"FJ3_CONTAG", "C", tamSX3("FJ3_CONTAG")[1], 0})
	aAdd(aStrFJ3, {"FJ3_CTASUP", "C", tamSX3("FJ3_CTASUP")[1], 0})
	aAdd(aStrFJ3, {"FJ3_DESCCG", "C", tamSX3("FJ3_DESCCG")[1], 0})
	aAdd(aStrFJ3, {"FJ3_DETHCG", "C", tamSX3("FJ3_DETHCG")[1], 0})
	aAdd(aStrFJ3, {"FJ3_NORMAL", "C", tamSX3("FJ3_NORMAL")[1], 0})
	aAdd(aStrFJ3, {"FJ3_COLUNA", "N", tamSX3("FJ3_COLUNA")[1], 0})
	aAdd(aStrFJ3, {"FJ3_CLASSE", "C", tamSX3("FJ3_CLASSE")[1], 0})
	aAdd(aStrFJ3, {"FJ3_IDENT" , "C", tamSX3("FJ3_IDENT")[1] , 0})
	aAdd(aStrFJ3, {"FJ3_NOME"  , "C", tamSX3("FJ3_NOME")[1]  , 0})
	aAdd(aStrFJ3, {"FJ3_LINHA" , "C", tamSX3("FJ3_LINHA")[1] , 0})
	aAdd(aStrFJ3, {"FJ3_SEDINI", "C", tamSX3("FJ3_SEDINI")[1], 0})
	aAdd(aStrFJ3, {"FJ3_SEDFIM", "C", tamSX3("FJ3_SEDFIM")[1], 0})
	aAdd(aStrFJ3, {"FJ3_FORMUL", "C", tamSX3("FJ3_FORMUL")[1], 0})
	aAdd(aStrFJ3, {"FJ3_TOTVIS", "C", tamSX3("FJ3_TOTVIS")[1], 0})
	aAdd(aStrFJ3, {"FJ3_VISENT", "C", tamSX3("FJ3_VISENT")[1], 0})
	aAdd(aStrFJ3, {"FJ3_SLDENT", "C", tamSX3("FJ3_SLDENT")[1], 0})
	aAdd(aStrFJ3, {"FJ3_FATSLD", "C", tamSX3("FJ3_FATSLD")[1], 0})

	if select("ttVis") > 0
		ttVis->(dbCloseArea())
	endIf

	if oTTvis <> nil
		oTTvis:Delete()
		oTTvis := nil
	endIf

	oTTvis := fwTemporaryTable():New("ttVis")  
	oTTvis:SetFields(aStrFJ3) 	
	oTTvis:AddIndex("1",{"FJ3_CODPLA","FJ3_CONTAG"})				
	oTTvis:Create()	
	//T�RMINO: Cria��o da tabela tempor�ria da vis�o gerencial financeira
	
	//INICIO: Defini��o de query para buscar a vis�o gerencial
	cQuery := "SELECT 0 as FJ3_REC, 0 AS FJ3_PAGO, 0 AS FJ3_DISP, FJ3.FJ3_FILIAL, FJ3.FJ3_CODPLA "
	cQuery += "  , FJ3.FJ3_ORDEM, FJ3.FJ3_CONTAG, FJ3.FJ3_CTASUP, FJ3.FJ3_DESCCG, FJ3.FJ3_DETHCG "
	cQuery += "  , FJ3.FJ3_NORMAL, FJ3.FJ3_COLUNA, FJ3.FJ3_CLASSE, FJ3.FJ3_IDENT, FJ3.FJ3_NOME "
	cQuery += "  , FJ3.FJ3_LINHA, FJ3.FJ3_SEDINI, FJ3.FJ3_SEDFIM, FJ3.FJ3_FORMUL, FJ3.FJ3_TOTVIS "
	cQuery += "  , FJ3.FJ3_VISENT, FJ3.FJ3_SLDENT, FJ3.FJ3_FATSLD "	
	cQuery += "FROM " + retSqlName("FJ3") + " FJ3 "
	cQuery += "WHERE FJ3.FJ3_CODPLA = '" + cCodVisao + "' "
	cQuery += "  AND FJ3.D_E_L_E_T_ = ' ' "
	
	cQuery := ChangeQuery(cQuery)
	//T�RMINO: Defini��o de query para buscar a vis�o gerencial escolhida no parametro

	//INICIO: Execu��o de insert para popular a vis�o gerencial com base na query anteriormente definida
	cTable  := oTTvis:GetRealName()		//Obtenho o nome f�sico da tabela tempor�ria no banco de dados
	cInsert := " INSERT "
	
	if allTrim(tcGetDb()) == "ORACLE"
		cInsert += " /*+ APPEND */ "
	endIf

	if allTrim(tcGetDb()) == "DB2"
		cQuery := strTran(cQuery, "FOR READ ONLY", "")
	endIf

	for nRow := 1 to len(aStrFJ3)
		cColuna += iIf(nRow > 1, "," + aStrFJ3[nRow, 1], aStrFJ3[nRow, 1])
	next nRow

	cInsert += " INTO " + cTable + " (" + cColuna + " ) " + cQuery

	//Executo o comando para alimentar a tabela tempor�ria
	processa({|| nProcQry := tcSQLExec(cInsert)})

	if nProcQry != 0
		userException(tcSqlError())
	endIf
	//T�RMINO: Execu��o de insert para popular a vis�o gerencial com base na query anteriormente definida
	
	//INICIO: Defini��o de query para leitura dos movimentos banc�rios
	if select("qSE5") > 0
		qSE5->(dbCloseArea())
	endIf

	dbSelectArea("SE5")
	cOrder := strTran(sqlOrder(indexKey()), "E5_DATA", "E5_DTDISPO")
	
	cQuery := "SELECT SE5.*, SED.ED_COND "
	cQuery += "FROM " + retSqlName("SE5") + " SE5 "
	cQuery += "INNER JOIN " + retSqlName("SED") + " SED "
	cQuery += "   ON SED.D_E_L_E_T_  = ' ' "
	cQuery += "  AND SED.ED_FILIAL   = '" + xFilial("SED") + "' "
	cQuery += "  AND SED.ED_CODIGO   = SE5.E5_NATUREZ " 
	cQuery += "WHERE SE5.D_E_L_E_T_  = ' ' "
	cQuery += "  AND SE5.E5_FILIAL   = '" + xFilial("SE5") + "' "
	cQuery += "  AND SE5.E5_DTDISPO >= '" + dToS(aRange[1]) + "' "
	cQuery += "  AND SE5.E5_DTDISPO <= '" + dToS(aRange[2]) + "' "
	cQuery += "  AND SE5.E5_SITUACA <> 'C' "
	cQuery += "  AND SE5.E5_DTCANBX  = ' ' "
	cQuery += "  AND SE5.E5_KEY      = ' ' "
	cQuery += "  AND SE5.E5_MOTBX   <> 'CMP' "
	cQuery += "  AND SE5.E5_TIPODOC NOT IN ('DC','JR','BA','MT','CM','D2','J2','M2','C2','V2','CX','CP','TL') "
	cQuery += "ORDER BY " + cOrder

	cQuery := changeQuery(cQuery)
	tcQuery cQuery new alias "qSE5"
	
	dbSelectArea("qSE5")
	qSE5->(dbGoTop())
	//T�RMINO: Defini��o de query para leitura dos movimentos banc�rios

	//INICIO: Leitura da movimenta��o banc�ria e aplica��o da vis�o gerencial financeira 
	dbSelectArea("ttVis")
	ttVis->(dbGoTop())

	dbSelectArea("qSE5")
	qSE5->(dbGoTop())

	//Tratamento de recebidos e pagos
	do while !qSE5->(eof())
		//Grava as movimenta��es do SE5 no tempor�rio de acordo com a Vis�o.
		ttVis->(dbGoTop())
		
		do while !ttVis->(eof())
			//Confere a natureza do registro 
			if allTrim(qSE5->E5_NATUREZ) >= allTrim(ttVis->FJ3_SEDINI) ;
				.and. allTrim(qSE5->E5_NATUREZ) <= allTrim(ttVis->FJ3_SEDFIM) 
				
				//Soma na propria linha da natureza
				ttVis->(recLock("ttVis", .f.))
				
				if qSE5->E5_RECPAG == "P"
					ttVis->FJ3_PAGO += qSE5->E5_VALOR
				else
					ttVis->FJ3_REC += qSE5->E5_VALOR
				endIf
				
				ttVis->(msUnLock())
				
				cSuperior := ttVis->FJ3_CTASUP 	//Conta Superior
				cIdenti	  := ttVis->FJ3_IDENT 	//Somar ou Subtrair
				nRecno    := ttVis->(Recno())
				
				//Procurar nas superiores e somar ou subtrair
				do while !empty(cSuperior)
					//Somar ou Subtrair conforme campo FJ3_IDENTI
					//if cSuperior == ttVis->FJ3_CONTAG
					if !ttVis->(dbSeek(cCodVisao + cSuperior))
						exit 
					else
						ttVis->(recLock("ttVis", .f.))
							
						if (qSE5->E5_RECPAG == "P")
							if (cIdenti == "1")
								ttVis->FJ3_PAGO += qSE5->E5_VALOR
							else
								ttVis->FJ3_PAGO -= qSE5->E5_VALOR
							endIf

							if qSE5->ED_COND != "D"
								ttVis->FJ3_CONTAG := "19999999"
								ttVis->FJ3_DESCCG := "ESTORNO DESPESA"
							endIf
						else
							if (cIdenti == "1")
								ttVis->FJ3_REC += qSE5->E5_VALOR
							else
								ttVis->FJ3_REC -= qSE5->E5_VALOR
							endIf

							if qSE5->ED_COND == "D"
								ttVis->FJ3_CONTAG := "18888888"
								ttVis->FJ3_DESCCG := "ESTORNO RECEITA"
							endIf
						endIf
				
						ttVis->(msUnLock())
						
						if cSuperior == ttVis->FJ3_CTASUP
							exit 
						else
							cSuperior := ttVis->FJ3_CTASUP
						endIf
					endIf
					
					//ttVis->(dbSkip(-1))
				endDo
				
				ttVis->(dbGoto(nRecno))// Posiciona no ultimo registro
			endIf
		
			ttVis->(dbSkip())
		endDo
		
		qSE5->(dbSkip())
	endDo
	//T�RMINO: Leitura da movimenta��o banc�ria e aplica��o da vis�o gerencial financeira 

	//INICIO: Leitura do resultante da vis�o gerencial para popular a tabela de resultados 
	ttVis->(dbGoTop())
	
	do while !ttVis->(eof())
		//S� levar em considera��o se estiver como SIM no VISENT
		if (ttVis->FJ3_VISENT == "1")
			ttRes->(recLock("ttRes", .t.))
			ttRes->CTACODE    := ttVis->FJ3_CONTAG
			ttRes->CTADESC    := ttVis->FJ3_DESCCG
			ttRes->CODDESC    := ttVis->FJ3_DESCCG
			ttRes->RECEBIDOS  := ttVis->FJ3_REC
			ttRes->PAGOS      := ttVis->FJ3_PAGO
			ttRes->ORDEM 	  := ttVis->FJ3_ORDEM
			ttRes->(msUnLock())
		endIf
		
		ttVis->(dbSkip())
	endDo
	//T�RMINO: Leitura do resultante da vis�o gerencial para popular a tabela de resultados 
	
	qSE5->(dbCloseArea())
	ttVis->(dbCloseArea())
	
	if oTTvis <> nil
		oTTvis:Delete()
		oTTvis := nil
	endIf
	
	//INICIO: Gera��o do XML para retorno 
	putHeader("Fluxo de Caixa")
	cXML += '<Recebimentos>'
	
	ttRes->(dbSetOrder(1))
	ttRes->(dbGoTop())
	
	do while !ttRes->(eof())
		if ttRes->RECEBIDOS > 0 
		    cXML += '    <Recebimento>'
		    cXML += '        <ContaContabil>' + allTrim(ttRes->CTACODE) + '</ContaContabil>'
		    cXML += '        <DescricaoConta>' + allTrim(ttRes->CTADESC) + '</DescricaoConta>'
		    cXML += '        <RecebimentoMes>' + allTrim(strTran(transform(ttRes->RECEBIDOS, "@E 999999999999.99"), ",", ".")) + '</RecebimentoMes>'
		    cXML += '    </Recebimento>'
		endIf
		
		ttRes->(dbSkip())
	endDo
	 
	cXML += '</Recebimentos>'

	ttRes->(dbSetOrder(1))
	ttRes->(dbGoTop())
	
	cXML += '<Pagamentos>'
	
	do while !ttRes->(eof())
		if ttRes->PAGOS > 0 
		    cXML += '    <Pagamento>'
		    cXML += '        <ContaContabil>' + allTrim(ttRes->CTACODE) + '</ContaContabil>'
		    cXML += '        <DescricaoConta>' + allTrim(ttRes->CTADESC) + '</DescricaoConta>'
		    cXML += '        <PagamentoMes>' + allTrim(strTran(transform(ttRes->PAGOS, "@E 999999999999.99"), ",", ".")) + '</PagamentoMes>'
		    cXML += '    </Pagamento>'
		endIf
		
		ttRes->(dbSkip())
	endDo
	 
	cXML += '</Pagamentos>'
	//T�RMINO: Gera��o do XML para retorno
	 
	ttRes->(dbCloseArea())
	 
	if oTTres <> nil
		oTTres:Delete()
		oTTres := nil
	endIf
return
