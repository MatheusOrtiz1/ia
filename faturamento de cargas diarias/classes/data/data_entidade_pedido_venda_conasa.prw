#include "totvs.ch"
#include "fatcargasdef.ch"

/*/{Protheus.doc} DataEntidadePedidoVendaCONASA
Classe DATA de entidade de pedido de venda
@type class
@author Rodrigo Godinho
@since 14/08/2023
/*/
CLASS DataEntidadePedidoVendaCONASA FROM LongNameClass
	METHOD New() CONSTRUCTOR
	METHOD Insert(oEntidade, cMsgErro)
	METHOD GetNatureza(oEntidade)
	METHOD GetRecISS(oEntidade)
	METHOD NumByIdZ29(cIdZ29)
	METHOD NextC9Agreg(cCodCli, cLojaCli)
	METHOD GetMayCode(cCode, cPrefix)
ENDCLASS

/*/{Protheus.doc} DataEntidadePedidoVendaCONASA::New
Construtor
@type method
@author Rodrigo Godinho
@since 14/08/2023
@return object, Instância da classe
/*/
METHOD New() CLASS DataEntidadePedidoVendaCONASA
Return

/*/{Protheus.doc} DataEntidadePedidoVendaCONASA::Insert
Cria um pedido de venda
@type method
@author Rodrigo Godinho
@since 15/08/2023
@param oEntidade, object, Entidade de pedido de venda CONASA
@param cMsgErro, character, Mensagem de erro ( receberá seu valor por referência )
@return logical, Se operação foi realizada com sucesso
/*/
METHOD Insert(oEntidade, cMsgErro) CLASS DataEntidadePedidoVendaCONASA
	Local lRet		:= .F.
	Local nOper		:= 3  // NÚMERO DA OPERAÇÃO (INCLUSÃO)
    Local aHeader	:= {} // INFORMAÇÕES DO CABEÇALHO
    Local aLine		:= {} // INFORMAÇÕES DA LINHA
    Local aItems	:= {} // CONJUNTO DE LINHAS
	Local nI		:= 0
	Local cTpFrete	:= AllTrim(GetMV("CO_PVTPFRE", , "S"))
	Local cUFPrest	:= AllTrim(GetMV("CO_PVUFPRS", , "SP"))
	Local cMunPrest	:= AllTrim(GetMV("CO_PVMUPRS", , "45209"))
	Local cCCusto	:= AllTrim(GetMV("CO_PVCCUST", , "28.01.002"))
	Local cCodOper	:= AllTrim(GetMV("CO_PVCOPER", , "07"))
	Local cNatureza	:= ::GetNatureza(oEntidade)
	Local cRecISS	:= ::GetRecISS(oEntidade)
	Local dEmissao	:= Iif(ValType(oEntidade) == "O" .And. !Empty(oEntidade:dDtEmissao), oEntidade:dDtEmissao, dDataBase)
	Local cHistCR	:= "PERIODO DE " + cValToChar(FirstDay(dEmissao)) + " A " + cValToChar(LastDay(dEmissao))
	Local aLogAuto	:= {}

    Private lMsErroAuto		:= .F.
    Private lMsHelpAuto		:= .T.
	private lAutoErrNoFile	:= .T.

	If ValType(oEntidade) == "O"
		// aAdd(aHeader, {"C5_TIPO", "N", Nil})
		aAdd(aHeader, {"C5_CLIENTE", oEntidade:cCodCLie, Nil})
		aAdd(aHeader, {"C5_LOJACLI", oEntidade:cLojaClie, Nil})
		If !Empty(oEntidade:dDtEmissao)
			aAdd(aHeader, {"C5_EMISSAO", oEntidade:dDtEmissao, Nil})
		EndIf
		aAdd(aHeader, {"C5_TPFRETE", cTpFrete, Nil})
		aAdd(aHeader, {"C5_RECISS", cRecISS, Nil})
		aAdd(aHeader, {"C5_ESTPRES", cUFPrest, Nil})
		aAdd(aHeader, {"C5_MUNPRES", cMunPrest, Nil})
		aAdd(aHeader, {"C5_UCCUSTO", cCCusto, Nil})
		aAdd(aHeader, {"C5_NATUREZ", cNatureza, Nil})
		aAdd(aHeader, {"C5_UHIST", cHistCR, Nil})
		If SC5->(FieldPos("C5_XIDZ29")) > 0 .And. !Empty(oEntidade:cIdZ29)
			aAdd(aHeader, {"C5_XIDZ29", oEntidade:cIdZ29, Nil})
		EndIf
		If SC5->(FieldPos("C5_XMSGNF")) > 0 .And. !Empty(oEntidade:cMsgNF)
			aAdd(aHeader, {"C5_XMSGNF", oEntidade:cMsgNF, Nil})
		EndIf

		For nI := 1 To Len(oEntidade:aItens)
			aAdd(aLine, {"C6_PRODUTO", oEntidade:aItens[nI]:cCodProd, Nil})
			aAdd(aLine, {"C6_QTDVEN", oEntidade:aItens[nI]:nQtdVend, Nil})
			aAdd(aLine, {"C6_QTDLIB", oEntidade:aItens[nI]:nQtdVend, Nil})
			If !Empty(oEntidade:aItens[nI]:nPrecoUnit)
				aAdd(aLine, {"C6_PRCVEN", oEntidade:aItens[nI]:nPrecoUnit, Nil})
			EndIf
			aAdd(aLine, {"C6_OPER", cCodOper, Nil})

			aAdd(aItems, aClone(aLine))
			aSize(aLine, 0)
		Next

		MsExecAuto({|x, y, z| MATA410(x, y, z)}, aHeader, aItems, nOper)

		If lMsErroAuto
			Default cMsgErro	:= ""
			
			aLogAuto := GetAutoGRLog()
			If ValType(aLogAuto) == "A"
				For nI := 1 To Len(aLogAuto)
					cMsgErro += aLogAuto[nI] + CRLF
				Next
			EndIf
		Else
			lRet := .T.
		EndIf
	EndIf
Return lRet

/*/{Protheus.doc} DataEntidadePedidoVendaCONASA::GetNatureza
Obtem a natureza para o pedido
@type method
@author Rodrigo Godinho
@since 15/08/2023
@param oEntidade, object, Entidade de pedido
@return character, Natureza
/*/
METHOD GetNatureza(oEntidade) CLASS DataEntidadePedidoVendaCONASA
	Local cRet		:= AllTrim(GetMV("CO_PVNATUR", , "31101003"))
	Local cNatClie	:= ""
	Local cKeySA1	:= ""
	If ValType(oEntidade) == "O"
		cKeySA1 := xFilial("SA1") + AvKey(oEntidade:cCodCLie, "A1_COD") + AvKey(oEntidade:cLojaClie, "A1_LOJA")
		cNatClie := GetAdvFVal("SA1", "A1_NATUREZ", cKeySA1, 1, "", .T.)
		If !Empty(cNatClie)
			cRet := cNatClie
		EndIf
	EndIf
Return cRet

/*/{Protheus.doc} DataEntidadePedidoVendaCONASA::GetRecISS
Retorna se cliente recolhe ISS
@type method
@author Rodrigo Godinho
@since 15/08/2023
@param oEntidade, object, Entidade do pedido
@return character, Valor referente ao campo de Recolhe ISS do cliente do pedido
/*/
METHOD GetRecISS(oEntidade) CLASS DataEntidadePedidoVendaCONASA
	Local cRet		:= ""
	Local cKeySA1	:= ""

	If ValType(oEntidade) == "O"
		cKeySA1 := xFilial("SA1") + AvKey(oEntidade:cCodCLie, "A1_COD") + AvKey(oEntidade:cLojaClie, "A1_LOJA")
		cRet := GetAdvFVal("SA1", "A1_RECISS", cKeySA1, 1, "", .T.)
	EndIf
Return cRet

/*/{Protheus.doc} DataEntidadePedidoVendaCONASA::NumByIdZ29
Retorna o número do pedido associado a uma carga
@type method
@author Rodrigo Godinho
@since 16/08/2023
@param cIdZ29, character, Id da carga
@return character, Número do pedido
/*/
METHOD NumByIdZ29(cIdZ29) CLASS DataEntidadePedidoVendaCONASA
	Local cRet			:= ""
	Local aArea			:= GetArea()
	Local cAliasQry		:= GetNextAlias()

	BeginSQL Alias cAliasQry
		SELECT C5_NUM
		FROM %Table:SC5%
		WHERE C5_FILIAL = %xFilial:SC5%
			AND C5_XIDZ29 = %Exp:cIdZ29%
			AND %NotDel%
	EndSQL
	If !(cAliasQry)->(Eof())
		cRet := (cAliasQry)->C5_NUM
	EndIf
	(cAliasQry)->(dbCloseArea())
	RestArea(aArea)
Return cRet

/*/{Protheus.doc} DataEntidadePedidoVendaCONASA::NextC9Agreg
Retorna o próximo código do C9_AGREG, para saber se o pedido ser agrupado no faturamento ou não
@type method
@author Rodrigo Godinho
@since 21/08/2023
@param cCodCli, character, Código do cliente
@param cLojaCli, character, Loja do cliente
@return character, Código do C9_AGREG
/*/
METHOD NextC9Agreg(cCodCli, cLojaCli) CLASS DataEntidadePedidoVendaCONASA
	Local cRet			:= ""
	Local aArea			:= GetArea()
	Local cAliasQry		:= GetNextAlias()
	Local lMayIUse		:= .F.
	Local cMayCode		:= ""

	BeginSQL Alias cAliasQry
		SELECT MAX(C9_AGREG) LAST_ITEM
		FROM %Table:SC9%
		WHERE C9_FILIAL = %xFilial:SC9%
			AND C9_CLIENTE = %Exp:cCodCli%
			AND C9_LOJA = %Exp:cLojaCli%
			AND C9_NFISCAL = ' '
			AND %NotDel%
	EndSQL
	If (cAliasQry)->(Eof())
		cRet := StrZero(1, TamSX3("C9_AGREG")[1], 0)
	Else
		cRet := Soma1((cAliasQry)->LAST_ITEM)
	EndIf
	cMayCode := ::GetMayCode(cRet, "C9_AGREG_")
	lMayIUse := MayIUseCod(cMayCode)
	While !lMayIUse
		cRet := Soma1(cRet)
		cMayCode := ::GetMayCode(cRet, "C9_AGREG_")
		lMayIUse := MayIUseCod(cMayCode)
	EndDo
	(cAliasQry)->(dbCloseArea())
	RestArea(aArea)
Return cRet

/*/{Protheus.doc} DataEntidadePedidoVendaCONASA::GetMayCode
Método de suporte para controle de concorrência, retorna o código no formato que a MayIUseCode deve usar
@type method
@author Rodrigo Godinho
@since 21/08/2023
@param cCode, character, Código
@param cPrefix, character, Prefixo
@return character, Código para usar com a MayIUseCode
/*/
METHOD GetMayCode(cCode, cPrefix) CLASS DataEntidadePedidoVendaCONASA
	Default cCode	:= ""
Return cPrefix + cEmpAnt + "_" + cFilAnt + "_" + cCode 
