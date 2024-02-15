#include "rwmake.ch"
#include "protheus.ch"
 
User Function MTA105LIN()
Local cLocal := aCols[n,aScan(aHeader,{|x| Alltrim(x[2])="CP_LOCAL"})]
Local cParam := SUPERGETMV("MV_UMTA105",.F.,.F.) //PARAMETRO PARA ATIVAR E DESATIVAR VALIDAÇÃO USUARIO X ARMAZEM
Local CALIAS := "ZAJ"
Local lRet   := .F. 
         
IF cParam

    DBSELECTAREA( CALIAS )
    dbSetOrder(1)
    DBGOTOP()

    WHILE ZAJ->(!EOF())

        IF cLocal == ZAJ->ZAJ_LOCAL
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
