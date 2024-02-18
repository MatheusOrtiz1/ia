#INCLUDE 'PROTHEUS.CH'

//------------------------------------------------------------------------------------
//Rotina:MT105FIM      Autor: Everton Forti     Data: 14/04/2023
//Desc.: Sempre bloquear SA mesmo que esteja solicitante esteja cadastrado
//------------------------------------------------------------------------------------
User Function MT105FIM()
Local nOpcap := PARAMIXB
Local MVAPROVSA := SUPERGETMV("MV_APROVSA",.F.,.F.)
Local _cNumCP   := SCP->CP_NUM
LOCAL AAREA     := GETAREA()
LOCAL AAREA_SCP := SCP->(GETAREA())

IF nOpcap == 1

    IF MVAPROVSA

        DBSELECTAREA("SCP")
        DBSETORDER( 1 )
        IF DBSEEK( xFilial("SCP")+_cNumCP,.T.)

            WHILE SCP->(!EOF()) .AND. xFilial("SCP")+_cNumCP == SCP->CP_FILIAL+SCP->CP_NUM

                IF RECLOCK("SCP",.F.)
                    SCP->CP_STATSA = "B"
                ENDIF

            SCP->(DBSKIP())
            ENDDO
        ENDIF

    ENDIF

ENDIF

RESTAREA(AAREA_SCP)
RestArea(aArea)

Return 
