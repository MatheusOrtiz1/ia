#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"
//------------------------------------------------------------------------------------
//Rotina:MTA107MNU      Autor: Everton Forti     Data: 11/04/2023
//Desc.: Adicionado Botão Rejeitar na tela de liberação solicitação ao armazem
//------------------------------------------------------------------------------------
User Function MTA107MNU()     

	AAdd(aRotina,{"Rejeitar SA"	,"U_CANCSCP()",0,0})
           
Return()

User Function CANCSCP()

LOCAL AAREA     := GETAREA()
LOCAL AAREA_SCP := SCP->(GETAREA())
LOCAL _cNumCP   := SCP->CP_NUM

IF MSGYESNO( "Deseja rejeitar a Solicitação?", "ATENÇÃO!" )

    DBSELECTAREA("SCP")
    DBSETORDER( 1 )
    IF DBSEEK( xFilial("SCP")+_cNumCP,.T.)

        WHILE SCP->(!EOF()) .AND. xFilial("SCP")+_cNumCP == SCP->CP_FILIAL+SCP->CP_NUM
            IF RECLOCK("SCP")
                SCP->CP_STATSA := 'R'
            MSUNLOCK()
            ENDIF
        SCP->(DBSKIP())
        ENDDO
    ENDIF

ENDIF

RESTAREA(AAREA_SCP)
RestArea(aArea)

RETURN()
