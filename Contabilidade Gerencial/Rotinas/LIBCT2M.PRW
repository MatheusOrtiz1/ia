#include 'totvs.ch'
#include "protheus.ch"
 /*
Programa.: LIBCT2M.prw 
Tipo.....: Ponto de entrada alteração do lançamento contabil
Autor....: Everton Forti
Data....:   28/09/2023
Descrição: LIBCT2M - Altera tipo de saldo 
*/
User Function LIBCT2M()
Local lULIBCT2	:=SuperGetMV("MV_ULIBCT2",.F.,"000000,000022,000133,000404") //Ativa Workflow Aprovação lançamento contabil manual
Private oProcess as object

IF __cUserID $ lULIBCT2

        oProcess := MsNewProcess():New({ || MANUALLIB() }, 'Liberando...', 'Aguarde...')
        oProcess:Activate() 
ELSE
    FWAlertHelp("Usuário sem acesso para Liberação Manual", "Acesso negado - MV_ULIBCT2")
ENDIF

RETURN

Static Function MANUALLIB()
Local cLote		:= CT2->CT2_LOTE
Local cSubLote	:= CT2->CT2_SBLOTE
Local cDoc		:= CT2->CT2_DOC
Local cFilori	:= CT2->CT2_FILIAL
Local dDataL	:= CT2->CT2_DATA

//Local nAtual,nLinha
//Local aCampos := {}


   DBSELECTAREA("CT2")
    DBSETORDER(1)//CT2_FILIAL+DTOS(CT2_DATA)+CT2_LOTE+CT2_SBLOTE+CT2_DOC+CT2_LINHA+CT2_TPSALD+CT2_EMPORI+CT2_FILORI+CT2_MOEDLC                                                     
    IF DBSEEK(cFilori+DTOS(dDataL)+cLote+cSubLote+cDoc)
        
        dCt2Dtx := CT2->CT2_DATA
        
        WHILE !EOF() .AND. CT2->CT2_FILIAL+DTOS(CT2->CT2_DATA)+CT2->CT2_LOTE+CT2->CT2_SBLOTE+CT2->CT2_DOC == cFilori+DTOS(dDataL)+cLote+cSubLote+cDoc	

            IF RECLOCK("CT2",.F.)
                CT2->CT2_TPSALD := "1"
                CT2->CT2_DTCONF := MsDate()
                CT2->CT2_USERAP := "Lançamento liberado pelo usuário "+__cUserID 
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
        
        FWAlertSuccess("LOTE liberado com sucesso", "Liberado")

        //AVISA QUE 
        //AVISAPROVADO(xFilial("CT2"),datalanc,lote,sublote,documento,solic,cMotivo)
    ENDIF

 
Return
