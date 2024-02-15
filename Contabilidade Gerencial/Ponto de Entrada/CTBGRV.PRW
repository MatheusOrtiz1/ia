#include 'totvs.ch'
#include "protheus.ch"
 /*
Programa.: CTBGRV.prw 
Tipo.....: Ponto de entrada alteração do lançamento contabil
Autor....: Everton Forti
Data....:   29/08/2023
Descrição: CTBGRV - Altera tipo de saldo 
*/
User Function CTBGRV()
Local nOpcLct := ""
local nProgra := ""
Local lATIVAWF	:=SuperGetMV("MV_UWFCT2",.F.,.F.) //Ativa Workflow Aprovação lançamento contabil manual
Private oProcess as object

IF lATIVAWF
    nOpcLct := paramixb[1]//Opção para lançamento (3-Inclusão; 4-Alteração;6-Estorno) 
    nProgra := paramixb[2]

    If nOpcLct == 4 .AND. FUNNAME() == nProgra//Alteração
        oProcess := MsNewProcess():New({ || ALTSLDTP9() }, 'Carregando...', 'Aguarde...')
        oProcess:Activate() 
    EndIf
ENDIF

RETURN

Static Function ALTSLDTP9()
Local cLote		:= CT2->CT2_LOTE
Local cSubLote	:= CT2->CT2_SBLOTE
Local cDoc		:= CT2->CT2_DOC
Local cFilori	:= CT2->CT2_FILIAL
Local dDataL	:= CT2->CT2_DATA
//Local nAtual,nLinha
//Local aCampos := {}


   DBSELECTAREA("CT2")
    DBSETORDER(1)
    IF DBSEEK(cFilori+DTOS(dDataL)+cLote+cSubLote+cDoc)
        
        dCt2Dtx := CT2->CT2_DATA
        
        WHILE !EOF() .AND. CT2->CT2_FILIAL+DTOS(CT2->CT2_DATA)+CT2->CT2_LOTE+CT2->CT2_SBLOTE+CT2->CT2_DOC == cFilori+DTOS(dDataL)+cLote+cSubLote+cDoc	

            IF RECLOCK("CT2",.F.)
                CT2->CT2_TPSALD := "9"
                CT2->CT2_DTCONF := MsDate()
                //CT2->CT2_UINFOR := "Lançamento alterado necessario Aprovecao via WF"
                MSUNLOCK()
            Conout('LANÇAMENTO CONTABIL LIBERADO: ') 
            ENDIF
        
        CT2->(DBSKIP())
        ENDDO
        //REPROCESSAMENTO SALDO CONTABIL
        //-------------------------------------------------------------------------------------------------
        _cTpSaldo := "1"
        dIniRep := ctod("")
            
        CTBA190(.T.,dDataL,dDataL,cFilAnt,cFilAnt,_cTpSaldo,.F.,"  ") 
        //-------------------------------------------------------------------------------------------------
        
        //AVISA QUE 
        //AVISAPROVADO(xFilial("CT2"),datalanc,lote,sublote,documento,solic,cMotivo)
    ENDIF

 
Return
