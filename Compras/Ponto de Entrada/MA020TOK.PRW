#Include "protheus.ch"
#Include "parmtype.ch"
#Include "fwmvcdef.ch"
#Include "tbiconn.ch"

USER FUNCTION MA020TOK()
	Local oModel := NIL
	Local lRet   := .T.
	Local cLog   := ""
	Local nOpc   := 3
	Local nX     := 0
	Local cCtbConta := ""
	LOCAL MV_UA2CTB
	LOCAL MV_UCTBSEQ
	LOCAL MV_UCTASQ2

	Private aMsLog := {}
	Private lMsErroAuto := .F.

	//PREPARE ENVIRONMENT EMPRESA "07" FILIAL "01" MODULO "CTB" TABLES "CT1", "CVD", "CVS"

	// EnvInfo("CTBA020.PRW")

	MV_UA2CTB := GETMV("MV_UA2CTB")
	MV_UCTBSEQ:= GETMV("MV_UCTBSEQ")
	MV_UCTASQ2:= GETMV("MV_UCTASQ2")

	IF MV_UA2CTB //Define se ira criar conta automaticamente ao cadastrar Clinte/Fornecedor

		IF MV_UCTBSEQ // Cria conta contabil sequencial para estas emrpesa 01,02,03,04,06,08,09

			MV_UCTASQ2 := MV_UCTASQ2+1 //Parametro numerico com a sequencia da conta de Fornecedor 21101001200001++
			cCtbConta  := cvaltochar(MV_UCTASQ2)
		Else
			cCtbConta  := M->A2_CONTA
		Endif

		saveInter() 	//Salva variaveis publicas

		If oModel == NIL
			oModel := FwLoadModel("CTBA020")
			oModel:SetOperation(nOpc)
			oModel:Activate()
		EndIf

		DBSELECTAREA("CT1")
		DBSETORDER(1)
		IF !DBSEEK(xFILIAL("CT1")+cCtbConta)
			oModel:SetValue("CT1MASTER",    "CT1_CONTA",     cCtbConta)
			oModel:SetValue("CT1MASTER",    "CT1_DESC01",    M->A2_NOME)
			oModel:SetValue("CT1MASTER",    "CT1_CLASSE",    "2")
			oModel:SetValue("CT1MASTER",    "CT1_NORMAL",    "2")
			oModel:SetValue("CT1MASTER",    "CT1_NTSPED",    "02")
			oModel:SetValue("CT1MASTER",    "CT1_GRUPO",     "2.1.01  ")
			oModel:SetValue("CT1MASTER",    "CT1_NORMAL",    "2")
			oModel:SetValue("CT1MASTER",    "CT1_CONSOL",    "S")
			oModel:SetValue("CT1MASTER",    "CT1_BOOK",    	 "1")
			oModel:SetValue("CT1MASTER",    "CT1_CTLALU",    cCtbConta)
			oModel:SetValue("CT1MASTER",    "CT1_SPEDST",    "2")
		ENDIF
		DBSELECTAREA("CVD")
		DBSETORDER(1)
		IF !DBSEEK(xFILIAL("CVD")+cCtbConta,.T.)
			oModel:SetValue("CVDDETAIL",    "CVD_FILIAL",    "")
			//		oModel:SetValue("CVDDETAIL",    "CVD_CONTA",     M->A2_CONTA)
			oModel:SetValue("CVDDETAIL",    "CVD_ENTREF",    "10")
			oModel:SetValue("CVDDETAIL",    "CVD_CODPLA",    "005")
			oModel:SetValue("CVDDETAIL",    "CVD_CTAREF",    "2.01.01.03.01")
			oModel:SetValue("CVDDETAIL",    "CVD_TPUTIL",    "A")
			oModel:SetValue("CVDDETAIL",    "CVD_CLASSE",    "2")
			oModel:SetValue("CVDDETAIL",    "CVD_VERSAO",    "0001")
			oModel:SetValue("CVDDETAIL",    "CVD_CUSTO",     "")
			oModel:SetValue("CVDDETAIL",    "CVD_NATCTA",    "02")
			oModel:SetValue("CVDDETAIL",    "CVD_CTASUP",    "2.01.01.03")
		/*
		oModel:SetValue("CTSDETAIL",    "CTS_FILIAL",     "")
		oModel:SetValue("CTSDETAIL",    "CTS_CODPLA",     "006")
		oModel:SetValue("CTSDETAIL",    "CTS_CONTAG",     "")
		*/
		ENDIF

		If oModel:VldData()
			oModel:CommitData()
		Else
			aLog := oModel:GetErrorMessage()

			For nX := 1 To Len(aLog)
				If !Empty(aLog[nX])
					cLog += Alltrim(aLog[nX]) + CRLF
				EndIf
			Next nX

			lMsErroAuto := .T.
			lRet := .F.

			AutoGRLog(cLog)
		EndIf


		oModel:DeActivate()
		restInter() 	//Restaura variaveis publicas
	Endif
	//RESET ENVIRONMENT
Return lRet
