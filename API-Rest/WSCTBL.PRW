#INCLUDE "restFul.ch"
#include "protheus.ch" 
#include "tbiConn.ch" 
#include "topConn.ch" 
#include "tryException.ch"

/*
Programa.: WSCTBL.PRW 
Tipo.....: Webservice Rest 
Autor....: Odair Batista - TOTVS Unidade Londrina
Data.....: 10/02/2020
Descrição: Webservice para consulta contábil  
Notas....: Retorna o balancete contábil e/ou demonstrativo de resultados (DRE) 
*/

#define str0001 "Serviço de Consulta a Dados Contábeis" 
#define str0002 "Método para Consulta Contábil" 


/*/{Protheus.doc} WSCTBL
Serviço para chamada externa
@author Odair Batista - TOTVS Unidade Londrina
@since 10/02/2020
@version 1.0
@type service
/*/
WsRestFul WSCTBL description str0001 
	WsData ClientID  as String 				//ID do ciente consumidor 
	WsData Company   as String				//Código da empresa 
	WsData Branch    as String optional		//Código da filial
	WsData Range     as String 				//Ano e mês para processamento
	WsData Model     as String 				//Modelo de relatório da consulta
	WsData ImpAnteLP as String 		     	//Indica se imprime lancamentos Lucros e Perdas
	WsData DatAnteLP as String 				//Data da ultima Apuracao de lancamentos Lucros e Perdas

	WsMethod Get description str0002 WsSyntax "/WSCTBL/{ClientID, Company, Branch, Range, Model}"
End WsRestFul 


/*/{Protheus.doc} Get 
Método para processamento da consulta
@author Odair Batista - TOTVS Unidade Londrina
@since 10/02/2020
@version 1.0
@type method
@param ClientID , caracter, ID do cliente consumidor
@param Company  , caracter, Código da empresa
@param Branch   , caracter, Código da filial
@param Range    , caracter, Ano e mês de processamento
@param Model    , caracter, Modelo de relatório (1=Balancete, 2=DRE, 3=Ambos)
@param ImpAnteLP, caracter, Indica se imprime lancamentos Lucros e Perdas (Sim/Nao)
@param DatAnteLP, caracter, Data da ultima Apuracao de lancamentos Lucros e Perdas ("20230503")
/*/
WsMethod Get WSReceive ClientID, Company, Branch, Range, Model, ImpAnteLP, DatAnteLP WsService WSCTBL 
 	local oException := nil
 	local aAlerts    := {}
 	local nRow       := 0
	local hasErrors  := .f.
  	
	private oAlerts  := nil
	private isHeader := .t.
	private cXML     := ""
	
	private cCodMun := ""
  	private aRange  := array(2)	 
  	
	default Self:ClientID  := "?"
	default Self:Company   := "27"
	default Self:Branch    := "01"
	default Self:Range     := strZero(year(date()), 4) + strZero(month(date()), 2)
	default Self:Model     := "1"
	default Self:ImpAnteLP := "Nao"
	default Self:DatAnteLP := space(8)

	rpcSetType(3)			                //Informa que não haverá consumo de licenças
	rpcSetEnv(Self:Company, Self:Branch)	//Prepara ambiente para empresa 01 e filial 01

	if valType(Self:ImpAnteLP) <> "C" ;
		.or. !upper(allTrim(fwNoAccent(Self:ImpAnteLP))) $ "SIM|NAO"

		Self:ImpAnteLP := .f.
	else 
		Self:ImpAnteLP := (upper(allTrim(fwNoAccent(Self:ImpAnteLP))) == "SIM")
	endIf

	if !Self:ImpAnteLP .or. valType(Self:DatAnteLP) != "C"
		Self:DatAnteLP := sToD(space(8))
	elseIf empty(Self:DatAnteLP)
		oAlerts:Add("17002" ;
					, "Data de Lucros/Perdas não informado!" ;
					, "E" ;
					, "Foi indicado a impressão de lançamentos de lucros e perdas, mas não foi informada a data " ;
					  + "de apuração. Verifique!")
	else 
		Self:DatAnteLP := sToD(Self:DatAnteLP)
	endIf 

	//Forçar sempre para Balancete Contábil
 	Self:Model := "1"

	//define o tipo de retorno do método
	Self:SetContentType("application/xml")

	oAlerts := tcAlerts():New()
	oAlerts:Empty()

	if !oAlerts:HasErrors()
		dbSelectArea("ZAA")
		ZAA->(dbSetOrder(1))	//ZAA_ID+ZAA_CODEMP
			
		Self:ClientID := padR(Self:ClientID, len(ZAA->ZAA_ID), " ")
	
		//Verifica permissão de visualização do cliente consumidor
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
							  + "a empresa [" + Self:Company + "] porque a data corrente esta fora do período de validade. Verifique!")
			endIf
		endIf
		
		if !oAlerts:HasErrors()
			tryException
				tryException
					cCodMun   := superGetMV("MV_UCODMUN", .f., "", cFilAnt)		
					aRange[1] := sToD(left(Self:Range, 4) + right(Self:Range, 2) + "01")	//Primeiro dia do mês/ano solicitado
					aRange[2] := lastDay(aRange[1])											//Último dia do mês/ano solicitado
					isHeader  := .t.
					
					openXML()
					
					if Self:Model == "1" .or. Self:Model == "3"	//Balancete
						doPutBAL()
					endIf

					if Self:Model == "2" .or. Self:Model == "3"	//DRE
						doPutDRE()
					endIf
					
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

	oAlerts:Destroy()

    rpcClearEnv() //volta a empresa anterior
return(!hasErrors)


/*/{Protheus.doc} addError
Função para adcionar erro por exceção
@author Odair Batista - TOTVS Unidade Londrina
@since 10/02/2020
@version 1.0
@type function
@param oException, objeto, Objeto da exceção do erro
/*/
static function addError(oException)
	local cDesc := ""
	local cHelp := ""
	
	if valType(oException) <> "O"
		cDesc := "Erro indeterminado!"
		cHelp := "Um erro não determinado ocorreu."
	else
		cDesc := oException:Description
		cHelp := oException:ErrorStack
	endIf
	
	oAlerts:Add("WSCTBL:Get" ;
				, cDesc ;
				, "E" ;
				, cHelp) 
return


/*/{Protheus.doc} openXML
Função para abertura do XML
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
Função para fechamento do XML
@author Odair Batista - TOTVS Unidade Londrina
@since 10/02/2020
@version 1.0
@type function
/*/
static function closeXML()
	cXML += '</root>'
return


/*/{Protheus.doc} putHeader
Função para inputar dados do cabeçalho
@author Odair Batista - TOTVS Unidade Londrina
@since 11/02/2020
@version 1.0
@type function
@param cTitle, caracter, Título para o cabeçalho
/*/
static function putHeader(cTitle)
	cXML += '<Cabecalho>'
	cXML += '<TipoDocumento>' + cTitle + '</TipoDocumento>'
	cXML += '<AnoExercicio>' + strZero(year(aRange[1]), 4) + '</AnoExercicio>'
	cXML += '<MesExercicio>' + mesExtenso(month(aRange[1])) + '</MesExercicio>'
	cXML += '<Municipio>' + cCodMun + '</Municipio>'
	cXML += '<DataCriacaoXML>' + strZero(year(date()), 4) + "-" + strZero(month(date()), 2) + "-" + strZero(day(date()), 2) + '</DataCriacaoXML>'
	cXML += '</Cabecalho>'
	
	isHeader := .f.
return


/*/{Protheus.doc} doPutBAL
Função para inputar dados do balancete no XML
@author Odair Batista - TOTVS Unidade Londrina
@since 11/02/2020
@version 1.0
@type function
/*/
static function doPutBAL()
	local cArqTmp := ""
	local cMoeda  := "01"
	local oMeter  := nil
	local oText	  := nil
	local oDlg	  := nil
	local isEnd	  := .f.
	local dSdoAnt := (aRange[1] - 1)
	local dDataLP := sToD(strZero(year(dSdoAnt), 4) + "0101")
	local nDivide := 1

	if !empty(Self:DatAnteLP)
		dDataLP := Self:DatAnteLP
	endIf 

	if isHeader
		putHeader("Balancete Contabil")
	endIf
	
	if select("cArqTmp") > 0
		cArqTmp->(dbCloseArea())
	endIf

	ctGerPlan(oMeter ;                                  //01-oMeter       = Controle da regua                                  
	          , oText ;                                 //02-oText        = Controle da regua                                  
              , oDlg ;                                  //03-oDlg         = Janela                                             
              , @isEnd ;                                //04-lEnd         = Controle da regua -> finalizar                     
              , @cArqTmp ;                              //05-cArqTmp      = Arquivo temporario                                 
              , aRange[1] ;                             //06-dDataIni     = Data Inicial de Processamento                     
              , aRange[2] ;                             //07-dDataFim     = Data Final de Processamento                        
              , "CT7" ;                                 //08-cAlias       = Alias do Arquivo                                   
              , "" ;                                    //09-cIdent       = Identificador do arquivo a ser processado          
              , "" ;                                    //10-cContaIni    = Conta Inicial                                      
              , replicate("Z", len(CT1->CT1_CONTA)) ;   //11-cContaFim    = Conta Final                                        
              , "" ;                                    //12-cCCIni       = Centro de Custo Inicial                            
              , replicate("Z", len(CTT->CTT_CUSTO)) ;   //13-cCCFim       = Centro de Custo Final                            
              , "" ;                                    //14-cItemIni     = Item Inicial                                       
              , replicate("Z", len(CTD->CTD_ITEM)) ;    //15-cItemFim     = Item Final                                         
              , "" ;                                    //16-cClvlIni     = Classe de Valor Inicial                            
              , replicate("Z", len(CTH->CTH_CLVL)) ;    //17-cClvlFim     = Classe de Valor Final                            
              , cMoeda ;                                //18-cMoeda       = Moeda                                               
              , "1" ;                                   //19-cSaldos      = Tipos de Saldo a serem processados                 
              , ctbSetOf("") ;                          //20-aSetOfBook   = Matriz de configuracao de livros                   
              , ;                                       //21-cSegmento    = Indica qual o segmento sera filtrado              
              , "" ;                                    //22-cSegIni      = Conteudo Inicial do segmento                     
              , replicate("Z", 20) ;                    //23-cSegFim      = Conteudo Final do segmento                         
              , ;                                       //24-cFiltSegm    = Filtra por Segmento                                  
              , .f. ;                                   //25-lNImpMov     = Se Imprime Entidade sem movimento                  
              , .f. ;                                   //26-lImpConta    = Se Imprime Conta                                   
              , ;                                       //27-nGrupo       = Grupo                                              
              , ;                                       //28-cHeader      = Identifica qual a Entidade Principal              
              , ImpAnteLP ;                             //29-lImpAntLP    = Se imprime lancamentos Lucros e Perdas             
              , dDataLP ;                               //30-dDataLP      = Data da ultima Apuracao de Lucros e Perdas       
              , nDivide ;                               //31-nDivide      = Divide valores por (100,1000,1000000)              
              , .f. ;                                   //32-lVlrZerado   = Grava ou nao valores zerados no arq temporario     
              , ;                                       //33-cFiltroEnt   = Entidade Gerencial que servira de filtro dentro de outra Entidade Gerencial. Ex.: Centro de Custo sendo filtrado por Item Contabil (CTH)
              , ;                                       //34-cCodFilEnt   = Codigo da Entidade Gerencial utilizada como filtro
              , ;                                       //35-cSegmentoG   = Filtra por Segmento Gerencial (CC/Item ou ClVl)    
              , ;                                       //36-cSegIniG     = Segmento Gerencial Inicial                         
              , ;                                       //37-cSegFimG     = Segmento Gerencial Final                           
              , ;                                       //38-cFiltSegmG   = Segmento Gerencial Contido em                     
              , ;                                       //39-lUsGaap      = Se e Balancete de Conversao de moeda              
              , ;                                       //40-cMoedConv    = Moeda para a qual buscara o criterio de conversao no Pl.Contas                                       
              , ;                                       //41-cConsCrit    = Criterio de conversao utilizado: 1-Diario, 2-Medio, 3-Mensal, 4-Informada, 5-Plano de Contas
              , ;                                       //42-dDataConv    = Data de Conversao                                  
              , ;                                       //43-nTaxaConv    = Taxa de Conversao                                  
              , ;                                       //44-aGeren       = Matriz que armazena os compositores do Pl. Ger. para efetuar o filtro de relatorio.              
              , ;                                       //45-lImpMov      = Nao utilizado                                      
              , ;                                       //46-lImpSint     = Se atualiza sinteticas                            
              , ;                                       //47-cFilUSU      = Filtro informado pelo usuario                     
              , ;                                       //48-lRecDesp0    = Se imprime saldo anterior do periodo anterior zerado                                             
              ,	;                              			//49-cRecDesp     = Grupo de receitas e despesas ('3456789')                     
              , dSdoAnt ;                               //50-dDtZeraRD    = Data de zeramento de receitas e despesas           
              , ;                                       //51-lImp3Ent     = Se e Balancete C.Custo / Conta / Item              
              , ;                                       //52-lImp4Ent     = Se e Balancete por CC x Cta x Item x Cl.Valor      
              , ;                                       //53-lImpEntGer   = Se e Balancete de Entidade (C.Custo/Item/Cl.Vlr por Entid. Gerencial)                            
              , ;                                       //54-lFiltraCC    = Se considera o filtro das perguntas para C.Custo   
              , ;                                       //55-lFiltraIt    = Se considera o filtro das perguntas para Item      
              , ;                                       //56-lFiltraCV    = Se considera o filtro das perguntas para Cl.Valor
              , cMoeda ;                                //57-cMoedaDsc    = Codigo da moeda para descricao das entidades       
              , ;                                       //58-lMovPeriodo  = Se imprime movimento do periodo anterior               
              , ;                                       //59-aSelFil      = Pode passar em branco
              , ;                                       //60-dDtCorte     = Pode passar em branco
              , ;                                       //61-lPlGerSint   = Pode passar em branco
              , .t. ;                                   //62-lConsSaldo   = Consolidar Saldo
              , ;                                       //63-lCompEnt     = Pode passar em branco
              , ;                                       //64-cArqAux      = Pode passar em branco
              , ;                                       //65-lUsaNmVis    = Pode passar em branco
              , ;                                       //66-cNomeVis     = Pode passar em branco
              , ;                                       //67-lCttSint     = Pode passar em branco
              , ;                                       //68-lTodasFil    = Pode passar em branco
              , ;                                       //69-cQuadroCTB   = Pode passar em branco
              , ;                                       //70-aEntidades   = Pode passar em branco
              , )                                       //71-cCodEntidade = Pode passar em branco               

	dbSelectArea("cArqTmp")
	cArqTmp->(dbGoTop())

	do while !cArqTmp->(eof())
		//Descartar contas detalhadas
		if len(allTrim(cArqTmp->CONTA)) > 8
		 	cArqTmp->(dbSkip())
		 	loop
		endIf
		
		cXML += '<BalanceteContabil>'
		cXML += '<ContaContabil>' + allTrim(cArqTmp->CONTA) + '</ContaContabil>'
		cXML += '<DescricaoConta>' + alltrim(cArqTmp->DESCCTA) + '</DescricaoConta>'
		cXML += '<SaldoInicial>' + allTrim(strTran(transform(iIf(cArqTmp->SALDOANT >= 0, cArqTmp->SALDOANT, (cArqTmp->SALDOANT * -1)), "@E 999999999999.99"), ",", ".")) + '</SaldoInicial>'
		cXML += '<NatInicial>' + iIf(cArqTmp->SALDOANT < 0, "D", "C") + '</NatInicial>'
		cXML += '<MovimentoCredito>' + allTrim(strTran(transform(cArqTmp->SALDOCRD, "@E 999999999999.99"), ",", ".")) + '</MovimentoCredito>'
		cXML += '<MovimentoDebito>' + allTrim(strTran(transform(cArqTmp->SALDODEB, "@E 999999999999.99"), ",", ".")) + '</MovimentoDebito>'
		cXML += '<SaldoFinal>' + allTrim(strTran(transform(iIf(cArqTmp->SALDOATU >= 0, cArqTmp->SALDOATU, (cArqTmp->SALDOATU * -1)), "@E 999999999999.99"), ",", ".")) + '</SaldoFinal>'
		cXML += '<NatFinal>' + iIf(cArqTmp->SALDOATU < 0, "D", "C") + '</NatFinal>'
		cXML += '</BalanceteContabil>'
		
		cArqTmp->(dbSkip())
	endDo

	cArqTmp->(dbCloseArea())
return


/*/{Protheus.doc} doPutDRE
Função para inputar dados do demonstrativo de resultado (DRE) no XML
@author Odair Batista - TOTVS Unidade Londrina
@since 10/02/2020
@version 1.0
@type function
/*/
static function doPutDRE()
	local cArqTmp := ""
	local cMoeda  := "01"
	local oMeter  := nil
	local oText	  := nil
	local oDlg	  := nil
	local isEnd	  := .f.
	local dSdoAnt := (aRange[1] - 1)
	local dDataLP := sToD(strZero(year(dSdoAnt), 4) + "0101")
	local nDivide := 1
	local cDesCta := ""
	
	if isHeader
		putHeader("Demonstrativo de Resultado")
	endIf
	
	if select("cArqTmp") > 0
		cArqTmp->(dbCloseArea())
	endIf
// CT2->CT2_ROTINA igual a CTBA211
	ctGerPlan(oMeter ;                                  //01-oMeter       = Controle da regua                                  
	          , oText ;                                 //02-oText        = Controle da regua                                  
              , oDlg ;                                  //03-oDlg         = Janela                                             
              , @isEnd ;                                //04-lEnd         = Controle da regua -> finalizar                     
              , @cArqTmp ;                              //05-cArqTmp      = Arquivo temporario                                 
              , aRange[1] ;                             //06-dDataIni     = Data Inicial de Processamento                     
              , aRange[2] ;                             //07-dDataFim     = Data Final de Processamento                        
              , "" ;                                    //08-cAlias       = Alias do Arquivo                                   
              , "" ;                                    //09-cIdent       = Identificador do arquivo a ser processado          
              , "" ;                                    //10-cContaIni    = Conta Inicial                                      
              , replicate("Z", len(CT1->CT1_CONTA)) ;   //11-cContaFim    = Conta Final                                        
              , "" ;                                    //12-cCCIni       = Centro de Custo Inicial                            
              , replicate("Z", len(CTT->CTT_CUSTO)) ;   //13-cCCFim       = Centro de Custo Final                            
              , "" ;                                    //14-cItemIni     = Item Inicial                                       
              , replicate("Z", len(CTD->CTD_ITEM)) ;    //15-cItemFim     = Item Final                                         
              , "" ;                                    //16-cClvlIni     = Classe de Valor Inicial                            
              , replicate("Z", len(CTH->CTH_CLVL)) ;    //17-cClvlFim     = Classe de Valor Final                            
              , cMoeda ;                                //18-cMoeda       = Moeda                                               
              , "1" ;                                   //19-cSaldos      = Tipos de Saldo a serem processados                 
              , ctbSetOf("999") ;                       //20-aSetOfBook   = Matriz de configuracao de livros                   
              , space(2) ;                              //21-cSegmento    = Indica qual o segmento sera filtrado              
              , space(20) ;                             //22-cSegIni      = Conteudo Inicial do segmento                     
              , replicate("Z", 20) ;                    //23-cSegFim      = Conteudo Final do segmento                         
              , space(30) ;                             //24-cFiltSegm    = Filtra por Segmento                                  
              , ;                                       //25-lNImpMov     = Se Imprime Entidade sem movimento                  
              , ;                                       //26-lImpConta    = Se Imprime Conta                                   
              , ;                                       //27-nGrupo       = Grupo                                              
              , ;                                       //28-cHeader      = Identifica qual a Entidade Principal              
              , .f. ;                                   //29-lImpAntLP    = Se imprime lancamentos Lucros e Perdas             
              , dDataLP ;                               //30-dDataLP      = Data da ultima Apuracao de Lucros e Perdas       
              , nDivide ;                               //31-nDivide      = Divide valores por (100,1000,1000000)              
              , .f. ;                                   //32-lVlrZerado   = Grava ou nao valores zerados no arq temporario     
              , ;                                       //33-cFiltroEnt   = Entidade Gerencial que servira de filtro dentro de outra Entidade Gerencial. Ex.: Centro de Custo sendo filtrado por Item Contabil (CTH)
              , ;                                       //34-cCodFilEnt   = Codigo da Entidade Gerencial utilizada como filtro
              , ;                                       //35-cSegmentoG   = Filtra por Segmento Gerencial (CC/Item ou ClVl)    
              , ;                                       //36-cSegIniG     = Segmento Gerencial Inicial                         
              , ;                                       //37-cSegFimG     = Segmento Gerencial Final                           
              , ;                                       //38-cFiltSegmG   = Segmento Gerencial Contido em                     
              , ;                                       //39-lUsGaap      = Se e Balancete de Conversao de moeda              
              , ;                                       //40-cMoedConv    = Moeda para a qual buscara o criterio de conversao no Pl.Contas                                       
              , ;                                       //41-cConsCrit    = Criterio de conversao utilizado: 1-Diario, 2-Medio, 3-Mensal, 4-Informada, 5-Plano de Contas
              , ;                                       //42-dDataConv    = Data de Conversao                                  
              , ;                                       //43-nTaxaConv    = Taxa de Conversao                                  
              , ;                                       //44-aGeren       = Matriz que armazena os compositores do Pl. Ger. para efetuar o filtro de relatorio.              
              , ;                                       //45-lImpMov      = Nao utilizado                                      
              , ;                                       //46-lImpSint     = Se atualiza sinteticas                            
              , ;                                       //47-cFilUSU      = Filtro informado pelo usuario                     
              , ;                                       //48-lRecDesp0    = Se imprime saldo anterior do periodo anterior zerado                                             
              ,	;                              			//49-cRecDesp     = Grupo de receitas e despesas ('3456789')                     
              , ;                               		//50-dDtZeraRD    = Data de zeramento de receitas e despesas           
              , ;                                       //51-lImp3Ent     = Se e Balancete C.Custo / Conta / Item              
              , ;                                       //52-lImp4Ent     = Se e Balancete por CC x Cta x Item x Cl.Valor      
              , ;                                       //53-lImpEntGer   = Se e Balancete de Entidade (C.Custo/Item/Cl.Vlr por Entid. Gerencial)                            
              , ;                                       //54-lFiltraCC    = Se considera o filtro das perguntas para C.Custo   
              , ;                                       //55-lFiltraIt    = Se considera o filtro das perguntas para Item      
              , ;                                       //56-lFiltraCV    = Se considera o filtro das perguntas para Cl.Valor
              , cMoeda ;                                //57-cMoedaDsc    = Codigo da moeda para descricao das entidades       
              , .t. ;                                   //58-lMovPeriodo  = Se imprime movimento do periodo anterior               
              , ;                                       //59-aSelFil      = Pode passar em branco
              , ;                                       //60-dDtCorte     = Pode passar em branco
              , .t. ;                                   //61-lPlGerSint   = Pode passar em branco
              , .f. ;                                   //62-lConsSaldo   = Consolidar Saldo
              , ;                                       //63-lCompEnt     = Pode passar em branco
              , ;                                       //64-cArqAux      = Pode passar em branco
              , ;                                       //65-lUsaNmVis    = Pode passar em branco
              , ;                                       //66-cNomeVis     = Pode passar em branco
              , ;                                       //67-lCttSint     = Pode passar em branco
              , ;                                       //68-lTodasFil    = Pode passar em branco
              , ;                                       //69-cQuadroCTB   = Pode passar em branco
              , ;                                       //70-aEntidades   = Pode passar em branco
              , ;                                       //71-cCodEntidade = Pode passar em branco               
              , ;
              , (aRange[1] - 1))

	dbSelectArea("cArqTmp")
	cArqTmp->(dbGoTop())

	do while !cArqTmp->(eof())
		//Indica se a entidade gerencial sera impressa/visualizada em na consulta após o processamento da visão
		if cArqTmp->VISENT == "2"
			cArqTmp->(dbSkip())
			loop
		endIf
	
		cDesCta := posicione("CTS", 2, xFilial("CTS") + "999" + cArqTmp->CONTA, "CTS_DETHCG")
		cDesCta := allTrim(cArqTmp->DESCCTA) + rTrim(cDesCta)
	
		cXML += '<BalanceteContabil>'
		cXML += '<ContaContabil>' + allTrim(cArqTmp->CONTA) + '</ContaContabil>'
		cXML += '<DescricaoConta>' + cDesCta + '</DescricaoConta>'
		cXML += '<SaldoInicial>' + allTrim(strTran(transform(iIf(cArqTmp->SALDOANT >= 0, cArqTmp->SALDOANT, (cArqTmp->SALDOANT * -1)), "@E 999999999999.99"), ",", ".")) + '</SaldoInicial>'
		cXML += '<NatInicial>' + iIf(cArqTmp->SALDOANT < 0, "D", "C") + '</NatInicial>'
		cXML += '<MovimentoCredito>' + allTrim(strTran(transform(cArqTmp->SALDOCRD, "@E 999999999999.99"), ",", ".")) + '</MovimentoCredito>'
		cXML += '<MovimentoDebito>' + allTrim(strTran(transform(cArqTmp->SALDODEB, "@E 999999999999.99"), ",", ".")) + '</MovimentoDebito>'
		cXML += '<SaldoFinal>' + allTrim(strTran(transform(iIf(cArqTmp->SALDOATU >= 0, cArqTmp->SALDOATU, (cArqTmp->SALDOATU * -1)), "@E 999999999999.99"), ",", ".")) + '</SaldoFinal>'
		cXML += '<NatFinal>' + iIf(cArqTmp->SALDOATU < 0, "D", "C") + '</NatFinal>'
		cXML += '</BalanceteContabil>'
		
		cArqTmp->(dbSkip())
	endDo

	cArqTmp->(dbCloseArea())
return
  