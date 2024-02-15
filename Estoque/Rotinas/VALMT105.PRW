#include "protheus.ch"

//-------------------------------------------------------------------------
//Rotina:VALMT105      Autor: Everton Forti     Data: 11/04/2023
//Desc.: Validação Local x Usuario Solicitação ao armazem
//--------------;-----------------------------------------------------------
User Function VALMT105()

Local cParam := SUPERGETMV("MV_UMTA105",.F.,.F.) //PARAMETRO PARA ATIVAR E DESATIVAR VALIDAÇÃO USUARIO X ARMAZEM
Local CALIAS := "ZAJ"
Local lRet   := .F.

IF cParam

    DBSELECTAREA( CALIAS )
    dbSetOrder(1)
    DBGOTOP()

    WHILE ZAJ->(!EOF())

        IF M->CP_LOCAL == ZAJ->ZAJ_LOCAL
            IF __CUSERID == ZAJ->ZAJ_USUARI
                lRet := .T.   
            ENDIF
        ENDIF

    ZAJ->(DBSKIP())
    ENDDO
ELSE
    lRet := .T.
ENDIF


IF !lRet
    MSGALERT( "Usuário não esta habilitado a utilizar este Local!", "MV_UMTA105 - U_VALMT105" )
ENDIF

Return(lRet)
