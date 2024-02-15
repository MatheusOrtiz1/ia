#Include "PROTHEUS.CH"
#include "RWMAKE.CH"
#include "TOPCONN.CH"
/*/{Protheus.doc} SF1100I
	Histórico do Financeiro
	@type  Function
	@author Everton Forti
	@since 24/06/2020
	/*/
USER FUNCTION SF1100I()
LOCAL ODLG      := NIL
LOCAL _cHist    := SPACE(100)
LOCAL _Itemcta	:= ""
LOCAL cQuery	:= ""
LOCAL _cClvl	:= ""
LOCAL LDUPLIC   := .F.
LOCAL CCUSTO    := ""
LOCAL AAREA     := GETAREA()
LOCAL AAREA_SE2 := SE2->(GETAREA())
LOCAL AAREA_SF1 := SF1->(GETAREA())
LOCAL XFORUNIAO := SuperGetMV("MV_UNIAO")
LOCAL XFORMUNIC := SuperGetMV("MV_MUNIC")
LOCAL XFORNISS  := SuperGetMV("MV_FORINSS")
LOCAL XFORSEST  := SuperGetMV("MV_FORSEST") 
LOCAL XNATISSR := SuperGetMV("MV_UNATISR",.F.,"") 

LOCAL _cNat,_cCc,_cCd,_cCusto,_cCredito,_cDebito,_nVlIss,_nVlIr,_nVlInss,_nVlcsll,_nVlpis,_nVlcof,_cCodfor,_cNomfor , I

PRIVATE ATAXAS    := {}

CopiaBcoConhec(SF1->F1_SERIE, SF1->F1_DOC, SF1->F1_FORNECE, SF1->F1_LOJA, SF1->F1_TIPO)

XFORUNIAO := PadR(SuperGetMV("MV_UNIAO"),TamSx3("A2_COD")[1])
cLojUniao  := PadR("000",TamSx3("A2_LOJA")[1])

cFornMun := PadR(SuperGetMV("MV_MUNIC"),TamSx3("A2_COD")[1])
cLojMun  := PadR("000",TamSx3("A2_LOJA")[1])

XFORUNIAO := XFORUNIAO+cLojUniao
XFORMUNIC := cFornMun+cLojMun

//IMPLEMENTADO TRATAMENTO ISS 02/09/2020
IF !EMPTY(CFORNISS)
	XFORMUNIC := CFORNISS+CLOJAISS
	CFORNISS  := XFORMUNIC
ENDIF

If Select("TMPD1") <> 0
	dbSelectArea("TMPD1")
	TMPD1->(dbCloseArea())
EndIf

cQuery := " Select D1_CLVL,D1_ITEMCTA From "+RetSqlName("SD1")+" "
cQuery += " Where D_E_L_E_T_ = ' ' and D1_FILIAL = '"+SF1->F1_FILIAL+"' " 
cQuery += " And D1_DOC = '"+SF1->F1_DOC+"' And D1_SERIE = '"+SF1->F1_SERIE+"' " 
cQuery += " And D1_FORNECE = '"+SF1->F1_FORNECE+"' And D1_LOJA = '"+SF1->F1_LOJA+"' And D1_CC <> ' ' "
TcQuery cQuery New Alias "TMPD1"  
dbSelectArea("TMPD1")
TMPD1->(dbGoTop())
	_cClvl 	 := TMPD1->D1_CLVL
	_Itemcta := TMPD1->D1_ITEMCTA
TMPD1->(dbCloseArea())


If Select("QRY") <> 0
	dbSelectArea("QRY")
	QRY->(dbCloseArea())
EndIf

cString := " Select D1_CC,  Max(D1_TOTAL) TOTAL From "+RetSqlName("SD1")+" "
cString += " Where D_E_L_E_T_ = ' ' and D1_FILIAL = '"+SF1->F1_FILIAL+"' " 
cString += " And D1_DOC = '"+SF1->F1_DOC+"' And D1_SERIE = '"+SF1->F1_SERIE+"' " 
cString += " And D1_FORNECE = '"+SF1->F1_FORNECE+"' And D1_LOJA = '"+SF1->F1_LOJA+"' And D1_CC <> ' ' "
cString += " Group By D1_CC "
cString += " Order By TOTAL DESC "
TcQuery cString New Alias "QRY"  
dbSelectArea("QRY")
QRY->(dbGoTop())
	CCUSTO := QRY->D1_CC
QRY->(dbCloseArea())

// VERIFICANDO SE GERA FINANCEIRO
	IF SF4->F4_DUPLIC == 'N'
		RETURN()
	ENDIF

	WHILE LEN(ALLTRIM(_cHist)) <= 10

		DEFINE MSDIALOG ODLG TITLE "Informe o Histórico do Título para o Financeiro" FROM 0, 0 TO 100,550  PIXEL

		@ 010,010 SAY "Descrição do Histórico" OF oDlg Pixel

		@ 020,010 MSGET _cHist SIZE 150, 9 Valid !Empty(_cHist) PICTURE "@!"OF oDlg Pixel

		@ 030,080 Button "Confirma" Size 35,10 PIXEL OF oDlg Action ( oDlg:End())

		ACTIVATE MSDIALOG oDlg CENTERED

	ENDDO

// VERIFICANDO SE GERA FINANCEIRO


DBSELECTAREA("SE2")
DBSETORDER(6)
IF DBSEEK(XFILIAL("SE2")+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_PREFIXO+SF1->F1_DOC)
	LDUPLIC := .T.
		_cNat 		:=SE2->E2_NATUREZ
		_cCc 		:=SE2->E2_CCC
		_cCd 		:=CCUSTO
		_cCusto 	:=CCUSTO
		_cCredito	:=SE2->E2_CREDIT
		_cDebito 	:=SE2->E2_DEBITO
		_nVlIss 	:=SE2->E2_VRETISS
		_nVlIr 		:=SE2->E2_VRETIRF
		_nVlInss 	:=SE2->E2_INSSRET
		_nVlcsll 	:=SE2->E2_VRETCSL
		_nVlpis 	:=SE2->E2_VRETPIS
		_nVlcof 	:=SE2->E2_VRETCOF
		_cCodfor 	:=SE2->E2_FORNECE
		_cNomfor 	:=SE2->E2_NOMFOR
		_cClvl		:=SE2->E2_CLVL
		_Itemcta	:=SE2->E2_ITEMCTA
					  
	WHILE SE2->(!EOF()) .AND. SE2->E2_FILIAL+SE2->E2_FORNECE+SE2->E2_LOJA+SE2->E2_PREFIXO+SE2->E2_NUM == XFILIAL("SE2")+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_PREFIXO+SF1->F1_DOC
		IF RECLOCK("SE2",.F.)
			
				SE2->E2_CCD 		:= CCUSTO
				SE2->E2_CCUSTO		:= CCUSTO
				SE2->E2_CO			:= SE2->E2_NATUREZ	
				SE2->E2_NAT2   		:= SE2->E2_NATUREZ
				SE2->E2_HIST		:= _cHist
				SE2->E2_CLVL 		:=_cClvl //Incluido _CLVL/_ITEM
				SE2->E2_ITEMCTA 	:=_Itemcta //Incluido _CLVL/_ITEM
				SE2->E2_UTPORI  	:= SF1->F1_ESPECIE

				
			SE2->(MSUNLOCK("SE2"))
			CpBCSF1SE2()
		ENDIF

		IF !EMPTY(SE2->E2_PARCIR)
			AADD(ATAXAS,SE2->E2_FILIAL+XFORUNIAO+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCIR+"TX ")
			AADD(ATAXAS,SE2->E2_FILIAL+XFORUNIAO+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCIR+"TX ")
		ENDIF
		IF !EMPTY(SE2->E2_PARCCOF)
			AADD(ATAXAS,SE2->E2_FILIAL+XFORUNIAO+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCCOF+"TX ")
			AADD(ATAXAS,SE2->E2_FILIAL+XFORUNIAO+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCCOF+"TX ")
		ENDIF
		IF !EMPTY(SE2->E2_PARCPIS)
			AADD(ATAXAS,SE2->E2_FILIAL+XFORUNIAO+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCPIS+"TX ")
			AADD(ATAXAS,SE2->E2_FILIAL+XFORUNIAO+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCPIS+"TX ")
		ENDIF
		IF !EMPTY(SE2->E2_PARCSLL)
			AADD(ATAXAS,SE2->E2_FILIAL+XFORUNIAO+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCSLL+"TX ")
			AADD(ATAXAS,SE2->E2_FILIAL+XFORUNIAO+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCSLL+"TX ")
		ENDIF
		IF !EMPTY(SE2->E2_PARCSES)
			AADD(ATAXAS,SE2->E2_FILIAL+XFORSEST+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCSES+"SES")
			AADD(ATAXAS,SE2->E2_FILIAL+XFORSEST+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCSES+"SES")
		ENDIF
		IF !EMPTY(SE2->E2_PARCISS)
			AADD(ATAXAS,SE2->E2_FILIAL+XFORMUNIC+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCISS+"ISS")
			AADD(ATAXAS,SE2->E2_FILIAL+XFORMUNIC+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCISS+"ISS")
		ENDIF
		IF !EMPTY(SE2->E2_PARCINS)
			AADD(ATAXAS,SE2->E2_FILIAL+XFORNISS+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCINS+"INS") //000009795
			AADD(ATAXAS,SE2->E2_FILIAL+XFORNISS+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCINS+"INS")
		ENDIF
		
		DBSELECTAREA("SE2")
		SE2->(DBSKIP())
	ENDDO
ENDIF

FOR I := 1 TO LEN(ATAXAS)
	DBSELECTAREA("SE2")
	DBSETORDER(6)//E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO  
	IF DBSEEK(ATAXAS[I])
		cRecno := recno()
			//--------------------------------------------------
			//ADICIONADO TRATAMENTO NATUREZA ISS 02/09/2020
			IF SE2->E2_TIPO == "ISS" 
				DBSELECTAREA("SA2")
				DBSETORDER(1)
				DBSEEK(xFilial("SA2")+SF1->F1_FORNECE+SF1->F1_LOJA)
			ENDIF
			//-------------------------------------------------
		IF !EMPTY(SE2->E2_TITPAI)
			IF RECLOCK("SE2",.F.)
				SE2->E2_CCC 	:=_cCc
				SE2->E2_CCD 	:=_cCd
				SE2->E2_NAT2	:= _cNat
				SE2->E2_CCUSTO 	:=_cCusto
				SE2->E2_CREDIT 	:=POSICIONE("SED",1,XFILIAL("SED")+SE2->E2_NATUREZ,"ED_CREDIT")
				SE2->E2_DEBITO 	:=POSICIONE("SED",1,XFILIAL("SED")+SE2->E2_NATUREZ,"ED_DEBITO")
				SE2->E2_HIST	:="RET."+ SUBSTR(ATAXAS[I],26,3)+" - "+ATAXAS[I]+"-"+POSICIONE("SA2",1,XFILIAL("SA2")+SF1->F1_FORNECE+SF1->F1_LOJA,"A2_NOME")
				//--------------------------------------------------
				//ADICIONADO TRATAMENTO NATUREZA ISS 02/09/2020
				IF SE2->E2_TIPO == "ISS" .AND. SA2->A2_RECISS == 'N'	
					SE2->E2_NATUREZ := XNATISSR
				ENDIF	
				//------------------------------------------------------
				//GRAVAR CLASSE DE VALOR E CONTA ORCAMENTARIA- 23/06/22
				SE2->E2_CLVL 	:=_cClvl //Incluido _CLVL/_ITEM
				SE2->E2_ITEMCTA	:=_Itemcta //Incluido _CLVL/_ITEM
				SE2->E2_CO		:= _cNat	
				//----------------------------------------------------
				SE2->(MSUNLOCK("SE2"))
				CpBCSF1SE2()
			ENDIF
		ENDIF
	ENDIF
NEXT

/* GRAVAR CAMPOS ESPECIFICOS
DBSELECTAREA("SF1")
IF RECLOCK("SF1",.F.)
	SF1->F1_DTSISTE := DATE()
	SF1->F1_UHORA   := TIME()
	SF1->F1_USUARIO := SUBSTR(CUSUARIO,7,15)
	MSUNLOCK("SF1")
ENDIF
*/


RESTAREA(AAREA_SE2)
RESTAREA(AAREA_SF1)
RESTAREA(AAREA)

RETURN()

/*/{Protheus.doc} CopiaBcoConhec
Copia os arquivos do banco de conhecimento dos pedidos de compra(SC7) para a nota de entrada(SF1)
@type function
@author Rodrigo Godinho
@since 28/11/2023
@param cSerieNF, character, Serie
@param cNumNF, character, Numero da NF
@param cCodFornec, character, Código do Fornecedor
@param cLojaFornec, character, Loja do Fornecedor
@param cTipo, character, Tipo
/*/
Static Function CopiaBcoConhec(cSerieNF, cNumNF, cCodFornec, cLojaFornec, cTipo)
	Local aArea		:= GetArea()
	Local oHlpCopia	:= CopiaDocsBCSC7SF1Helper():New()

	oHlpCopia:Copia(cSerieNF, cNumNF, cCodFornec, cLojaFornec, cTipo, .T.)

	FreeObj(oHlpCopia)

	RestArea(aArea)
Return

/*/{Protheus.doc} CpBCSF1SE2
Copia os documentos doo banco de conhecimento da SF1 posicionada para a SE2 posicionada
@type function
@author Rodrigo Godinho
@since 29/11/2023
/*/
Static Function CpBCSF1SE2()
	Local oDataBC	:= BancoDeConhecimentoData():New() 
	Local aDocs		:= {}
	Local aArea		:= GetArea()
	Local aAreaSF1	:= SF1->(GetArea())
	Local aAreaSE2	:= SE2->(GetArea())
	Local nI		:= 0
	Local cMsgErro	:= ""
	Local oEntCopia

	aDocs := oDataBC:GetByEntidade("SF1")
	For nI := 1 To Len(aDocs)
		oEntCopia := EntidadeAC9():New()
		oEntCopia:cEntidade := "SE2"
		oEntCopia:oEntACB := aDocs[nI]:oEntACB
		oDataBC:CreateRelation(oEntCopia, @cMsgErro)
		FreeObj(oEntCopia)
	Next

	FreeObj(oDataBC)

	RestArea(aAreaSE2)
	RestArea(aAreaSF1)
	RestArea(aArea)
Return
