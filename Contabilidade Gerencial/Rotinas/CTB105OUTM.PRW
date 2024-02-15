#include "PROTHEUS.CH"  
#include "TBICONN.CH" 
//-------------------------------------------------------------------------------------------
//@author 	Eveorton Forti              DATA: 22/06/2021              Cliente: CONASA
//-------------------------------------------------------------------------------------------
//O ponto de entrada CTB105OUTM é executado ao final da validação da inclusão de um documento
//contábil, seja por inclusão manual, seja pelo processo de contabilização de integração.
//--------------------------------------------------------------------------------------------
USER FUNCTION CTB105OUTM()
LOCAL AAREA     := GETAREA()
LOCAL AAREA_CT2 := CT2->(GETAREA())
Local dDataLanc := PARAMIXB[1]
Local cLote     := PARAMIXB[2]
Local cSubLote  := PARAMIXB[3]
Local cDoc      := PARAMIXB[4]
Local lRet      := .T.
//Local cMensagem := ""
Local lATIVAWF	:=SuperGetMV("MV_UWFCT2",.F.,.F.) //Ativa Workflow Aprovação lançamento contabil manual

IF FUNNAME() == "CTBA102"
    IF lATIVAWF .AND. (INCLUI) 

        DBSELECTAREA("CT2")
        DBSETORDER(1)
        IF DBSEEK(xFilial("CT2")+DTOS(dDataLanc)+cLote+cSubLote+cDoc)//CT2_FILIAL+DTOS(CT2_DATA)+CT2_LOTE+CT2_SBLOTE+CT2_DOC+CT2_LINHA+CT2_TPSALD+CT2_EMPORI+CT2_FILORI+CT2_MOEDLC
            IF CT2->CT2_ROTINA == "CTBA102   "
                IF CT2->CT2_LOTE == "000500"
                    CONOUT("NÃO DISPARA WF PARA LOTE 000500 CONFORME SOLICITADO PELO USUARIO RODRIGO")
                ELSE
                    //Dispara o Workflow
                    U_WFCT2()
                ENDIF
            ENDIF
        ENDIF
    endif
ENDIF

RESTAREA(AAREA_CT2)
RESTAREA(aArea)


RETURN lRet
