#include "totvs.ch"
#include "rptdef.ch"

/*/{Protheus.doc} COCNTR01
Relatorio de lista simples de contratos
@type function
@author Rodrigo Godinho
@since 09/01/2024
/*/
User Function COCNTR01()
	Local oReport	:= ReportDef()
	oReport:PrintDialog()
Return

/*/{Protheus.doc} ReportDef
Definicao das configuracoes do relatorio
@type function
@author Rodrigo Godinho
@since 09/01/2024
@return object, Objeto TReport
/*/
Static Function ReportDef()
	Local oReport
	Local oTitSection
	Local cReport	:= "COCNTR01"
	Local cTitulo	:= "Lista de Contratos"
	Local cPergunta	:= "COCNTR01"

	Pergunte(cPergunta, .F.)
	
	oReport := TReport():New(cReport, cTitulo, cPergunta, {|oReport| ReportPrint(oReport)}, cTitulo)
	oReport:SetLandscape()
	// oReport:SetTotalInLine(.F.)
	// Pergunte(oReport:uParam,.F.)
	oTitSection := TRSection():New(oReport,"Contratos",{"CN9"},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/)
	// oTitSection:SetTotalInLine(.F.)

	TRCell():New(oTitSection,"CN9_NUMERO",	"CN9", RetTitle("CN9_NUMERO"),	PesqPict("CN9","CN9_NUMERO"), TamSx3("CN9_NUMERO")[1]+8,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oTitSection,"DOC_FORNEC",	""   , "CNPJ/CPF"            , "@!"                         , TamSx3("A2_CGC")[1]+8,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oTitSection,"A2_NOME",		"SA2", "Contratada"          ,	PesqPict("SA2","A2_NOME")   , TamSx3("A2_NOME")[1],/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oTitSection,"CN9_VLATU",	"CN9", "Valor Total Contrato",	PesqPict("CN9","CN9_VLATU") , TamSx3("CN9_VLATU")[1]+4,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oTitSection,"CN9_SALDO",	"CN9", "Saldo do Contrato"   ,	PesqPict("CN9","CN9_SALDO") , TamSx3("CN9_SALDO")[1]+4,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oTitSection,"CN9_DTINIC",	"CN9", "Data Inicio Contrato",	PesqPict("CN9","CN9_DTINIC"), TamSx3("CN9_DTINIC")[1]+2,/*lPixel*/,/*{|| code-block de impressao }*/, "CENTER")
	TRCell():New(oTitSection,"CN9_DTFIM",	"CN9", "Data Final Contrato" ,	PesqPict("CN9","CN9_DTFIM") , TamSx3("CN9_DTFIM")[1]+2,/*lPixel*/,/*{|| code-block de impressao }*/, "CENTER")
	TRCell():New(oTitSection,"CN9_OBJCTO",	"CN9", "Objeto do Contrato"  ,								, TamSx3("CN9_OBJCTO")[1],/*lPixel*/,/*{|| code-block de impressao }*/, , .T.)

Return oReport

/*/{Protheus.doc} ReportPrint
Funcao de execucao da impressao
@type function
@author Rodrigo Godinho
@since 09/01/2024
@param oReport, object, Objeto TReport
/*/
Static Function ReportPrint(oReport)
	Local cAliasQry := GetNextAlias()
	Local cAuxWhere	:= ""
	Local cCondVig	:= ""

	cAuxWhere += "%"
	// Condição para filtrar Vigentes
	If MV_PAR01 <> 3
		cCondVig := " CN9_SITUAC = '05' AND " + ValToSQL(dDataBase) + " BETWEEN CN9_DTINIC AND CN9_DTFIM "
		// Só vigentes
		If MV_PAR01 == 1
			cAuxWhere += " AND " + cCondVig
		// Só não vigentes
		ElseIf MV_PAR01 == 2
			cAuxWhere += " AND NOT (" + cCondVig + ")" 
		EndIf
	EndIf
	cAuxWhere += "%"

	dbSelectArea("CN9")
	dbSetOrder(1)
	oReport:Section(1):BeginQuery()
	BeginSql Alias cAliasQry
		COLUMN CN9_DTINIC AS DATE
		COLUMN CN9_DTFIM AS DATE
		SELECT CN9_NUMERO, A2_TIPO, A2_CGC, A2_NOME, CN9_VLATU, CN9_SALDO, CN9_DTINIC, CN9_DTFIM, CN9_CODOBJ
		FROM %Table:CN9% CN9
		JOIN %Table:CNC% CNC ON CNC_FILIAL = %xFilial:CNC% AND CNC_NUMERO = CN9_NUMERO AND CNC.CNC_REVISA = CN9.CN9_REVISA AND CNC.%NotDel%
		JOIN %Table:SA2% SA2 ON A2_FILIAL = %xFilial:SA2% AND A2_COD = CNC_CODIGO AND A2_LOJA = CNC_LOJA AND SA2.%NotDel%
		WHERE CN9_FILIAL = %xFilial:CN9%
			AND CN9_REVATU = ' '
			AND CN9_ESPCTR = '1'
			AND CN9_DTINIC BETWEEN %Exp:MV_PAR02% AND %Exp:MV_PAR03%
			AND CN9_DTFIM BETWEEN %Exp:MV_PAR04% AND %Exp:MV_PAR05%
			AND A2_COD BETWEEN %Exp:MV_PAR06% AND %Exp:MV_PAR07%
			AND A2_LOJA BETWEEN %Exp:MV_PAR08% AND %Exp:MV_PAR09%
			AND CN9.%NotDel%
			%Exp:cAuxWhere%
		ORDER BY CN9_FILIAL, CN9_NUMERO, A2_CGC	
	EndSql 	
	oReport:Section(1):EndQuery(/*Array com os parametros do tipo Range*/)

	oReport:Section(1):Cell("DOC_FORNEC"):SetBlock( { || FormatCGC((cAliasQry)->A2_CGC, (cAliasQry)->A2_TIPO) } )
	oReport:Section(1):Cell("CN9_OBJCTO"):SetBlock( { || GetObjInfo((cAliasQry)->CN9_CODOBJ, oReport:nDevice, ) } )

	oReport:SetMeter((cAliasQry)->(LastRec()))
	oReport:Section(1):Print() 

	If Select(cAliasQry) > 0
		(cAliasQry)->(dbCloseArea())
	EndIf

Return

/*/{Protheus.doc} GetObjInfo
Função de suporte para retornar o objeto do contrato e se necessário truncá-lo
@type function
@author Rodrigo Godinho
@since 26/01/2024
@param cIdMemoObj, character, Id do memo "virtual" ( baseado na SYP )
@param nDevice, numeric, Tipo de impressão
@param nSizeStr, numeric, Tamanho máximo ( será utilizado somente se o tipo for diferente de planilha)
@return character, Texto do objeto do contrato
/*/
Static Function GetObjInfo(cIdMemoObj, nDevice, nSizeStr)
	Local cRet	:= ""

	Default cIdMemoObj	:= ""
	Default nDevice		:= 0

	If !Empty(cIdMemoObj)
		cRet := AllTrim(MSMM(cIdMemoObj))
		If nDevice != IMP_EXCEL .And. !Empty(nSizeStr) .And. Len(cRet) > nSizeStr
			cRet := SubStr(cRet, 1, nSizeStr) + "..."
		EndIf
	EndIf
Return cRet

/*/{Protheus.doc} FormatCGC
Formata com o conteúdo do campo de CGC do fornecedor de acordo com o tipo, se é pessoa física ou jurídica
@type function
@author Rodrigo Godinho
@since 26/01/2024
@param cCGC, character, Conteudo do campo de CGC
@param cTipo, character, Tipo de pessoa ( F ou J, sendo J o valor padrão)
@return character, CGC formatado
/*/
Static Function FormatCGC(cCGC, cTipo)
	Local cRet		:= ""
	Local cPicture	:= ""

	Default cCGC	:= ""
	Default cTipo	:= "J"

	If !Empty(cCGC)
		cPicture := PictTpPessoa(cTipo)
		If Empty(cPicture)
			cRet := cCGC
		Else
			cRet := Transform(cCGC, cPicture)
		EndIf
	EndIf
Return cRet

/*/{Protheus.doc} PictTpPessoa
Função de suporte que devolve a picture de acordo com o tipo de pessoa ( F-Física ou J-Juridica )
@type function
@author Rodrigo Godinho
@since 29/01/2024
@param cTipo, character, Tipo de Pessoa (F ou J)
@return character, Picture
/*/
Static Function PictTpPessoa(cTipo)
	Local cRet := "@R 99.999.999/9999-99"

	Default cTipo	:= "J"

	If cTipo == "F"
		cRet := "@R 999.999.999-99"
	EndIf
Return cRet
