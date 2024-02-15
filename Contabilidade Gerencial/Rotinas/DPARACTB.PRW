#include "protheus.ch"
#INCLUDE "RWMAKE.CH"
/*
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDPARACTB  บAutor  ณEVERTON FORTI        บ Data ณ  26/02/16  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณDE PARA DE CONTAS CONTABEIS COM A TABELA Z99 DE ACORDO COM  บฑฑ
ฑฑบ          ณA TABELA E CAMPO PASSADOS PELO USUSARIO					  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ CONASA                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
*/

USER FUNCTION DPARACTB()

PRIVATE ODLG      := NIL
PRIVATE ALIAS     := SPACE(03) //CT1
PRIVATE CCONTA     := SPACE(09) //CT1_CONTA

DEFINE MSDIALOG ODLG TITLE "De->Para de Contas Contabeis com a tabela Z99" FROM 0, 0 TO 200,550  PIXEL

@ 010,010 SAY "Informa a Tabela Ex.: CT1" OF oDlg Pixel

@ 020,010 MSGET ALIAS SIZE 30, 9 Valid !Empty(ALIAS) PICTURE "@!"OF oDlg Pixel

@ 040,010 SAY "Informa o Campo da Conta Contแbil Ex.: CT1_CONTA  " OF oDlg Pixel

@ 060,010 MSGET CCONTA SIZE 30, 9 Valid !Empty(CCONTA) PICTURE "@!"OF oDlg Pixel

@ 080,080 Button "Confirma" Size 35,10 PIXEL OF oDlg Action ( oDlg:End())

ACTIVATE MSDIALOG oDlg CENTERED

//Alias := &(Alias)

DBSELECTAREA(Alias)
DBSetorder(1)
DBGotop()
                                               
// cIndici := STRTRAN(cIndici)  
 
While Alias->(!EOF())
	
	DBSELECTAREA("Z99")
	DBSETORDER(1)
	  cIndici := Alias+"->"+CCONTA
      cIndici := &(cIndici)
		IF DBSEEK(xFilial()+cIndici)
		Return()
		IF RECLOCK(Alias,.F.)
			Return()
			cIndici:= Z99->Z99_VLRNOV
			MSUNLOCK(Alias)
		ENDIF
	ENDIF
	Z99->(DBCLOSEAREA())
	(cAlias)->( DbSkip() )
ENDDO

RETURN()
