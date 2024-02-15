#include "protheus.ch"
#include "TOPCONN.CH"
#include "RWMAKE.CH"
#include "tbiconn.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma³ MA020TOK     ºAutor Everton Forti 	    º Data ³  17/03/2016 º±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºDesc.     ³ Ponto de entrada na confirmacao da inclusao do Cliente.    ±±
±±º          ³ Utilizado para criar uma conta contabil automaticamente.   ±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User function M030INC()

LOCAL MV_UA1CTB := GETMV("MV_UA1CTB")
LOCAL MV_UCTBSEQ:= GETMV("MV_UCTBSEQ")
LOCAL MV_UCTASQ1:= GETMV("MV_UCTASQ1")
LOCAL cCtbConta := SA1->A1_CONTA
Local aArea := GetArea()
Local cSvFilAnt := cFilAnt //Salva a Filial Anterior
Local cSvEmpAnt := cEmpAnt //Salva a Empresa Anterior
Local cSvArqTab := cArqTab //Salva os arquivos de //trabalho
Local lCVDOK	:= .T.
Local nX
Local oModel := NIL
Local cLog   := ""
Local nOpc   := 3

Private aMsLog := {}
Private lMsErroAuto := .F.


IF MV_UA1CTB   //Define se ira criar conta automaticamente ao cadastrar Cleinte/Fornecedor
	
	saveInter() 	//Salva variaveis publicas

	IF MV_UCTBSEQ // Cria conta contabil sequencial para estas emrpesa 01,02,03,04,06,08,09
		
		MV_UCTASQ1 := MV_UCTASQ1+1
		cCtbConta  := cvaltochar(MV_UCTASQ1)

	ENDIF
		
		DBSELECTAREA("CT1")
        CT1->(DBSETORDER(1))
        IF !CT1->(DBSEEK(XFILIAL("CT1")+cCtbConta)) .AND. !EMPTY(cCtbConta)

            If oModel == NIL
                oModel := FwLoadModel("CTBA020")
                oModel:SetOperation(nOpc)
                oModel:Activate()
            EndIf

            oModel:SetValue("CT1MASTER",    "CT1_CONTA",     cCtbConta)
            oModel:SetValue("CT1MASTER",    "CT1_DESC01",    SA1->A1_NOME)
            oModel:SetValue("CT1MASTER",    "CT1_CLASSE",    "2")
            oModel:SetValue("CT1MASTER",    "CT1_NORMAL",    "1")
            oModel:SetValue("CT1MASTER",    "CT1_NTSPED",    "01")
            oModel:SetValue("CT1MASTER",    "CT1_GRUPO",     "1.1.02.0")
            oModel:SetValue("CT1MASTER",    "CT1_NORMAL",    "1")
            //oModel:SetValue("CT1MASTER",    "CT1_CONSOL",    "S")
            oModel:SetValue("CT1MASTER",    "CT1_BOOK",    	 "001")
            oModel:SetValue("CT1MASTER",    "CT1_CTLALU",    cCtbConta)
            oModel:SetValue("CT1MASTER",    "CT1_SPEDST",    "")

			DBSELECTAREA("CVD")
			DBSETORDER(1)
			IF !DBSEEK(XFILIAL()+cCtbConta)

				oModel:SetValue("CVDDETAIL",    "CVD_FILIAL",    "")
				//oModel:SetValue("CVDDETAIL",    "CVD_CONTA",     cCtbConta)
				oModel:SetValue("CVDDETAIL",    "CVD_ENTREF",    "10")
				oModel:SetValue("CVDDETAIL",    "CVD_CODPLA",    "005")
				oModel:SetValue("CVDDETAIL",    "CVD_CTAREF",    "1.01.02.02.01")
				oModel:SetValue("CVDDETAIL",    "CVD_TPUTIL",    "A")
				oModel:SetValue("CVDDETAIL",    "CVD_CLASSE",    "2")
				oModel:SetValue("CVDDETAIL",    "CVD_VERSAO",    "0001")
				oModel:SetValue("CVDDETAIL",    "CVD_CUSTO",     "")
				oModel:SetValue("CVDDETAIL",    "CVD_NATCTA",    "02")
				oModel:SetValue("CVDDETAIL",    "CVD_CTASUP",    "1.01.02.02")
				/*
				oModel:SetValue("CTSDETAIL",    "CTS_FILIAL",     "")
				oModel:SetValue("CTSDETAIL",    "CTS_CODPLA",     "005")
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
                lCVDOK := .F.

                AutoGRLog(cLog)
                MostraErro()
			EndIf

		ENDIF

	
	ENDIF

	//Restaura os Dados de Entrada ( Ambiente )
	cFilAnt := cSvFilAnt
	cEmpAnt := cSvEmpAnt
	cArqTab := cSvArqTab
	
	//Restaura os ponteiros das Tabelas
	RestArea( aArea )

	restInter() 	//Restaura variaveis publicas


RETURN

