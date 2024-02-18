#include "protheus.ch"

//-------------------------------------------------------------------------
//Rotina:MDTA6959      Autor: Everton Forti     Data: 28/04/2023
//Desc.: Alerta usuario sobre a data de fechamento contabil
//-------------------------------------------------------------------------
USER FUNCTION MT103PN()
Local lRet := .T.

IF Day(DDATABASE) >= 25 .AND.  DAY(DDATABASE) <= 31
    IF MSGYESNO( "DESEJA CONTINUAR?", "Período corresponde a data de fechamento contábil!" )
        lRet := .T.
    ELSE
        lRet := .F.
    ENDIF
ENDIF

Return(lRet)
