/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CT5SZG    ºAutor  ³Microsiga           º Data ³  05/02/2010 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Programa para posicionamento no cadastro de "Contabilizacaoº±±
±±º          ³ motivo de baixa" e retorno de campos.                      º±±
±±º          ³                                                            º±±
±±º          ³ Parametros:                                                º±±
±±º          ³ CMOTBX Motivo da baixa                                     º±±
±±º          ³ NRET   Tipo do retorno                                     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Disponibilizado por Helena Shigueoka                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

USER FUNCTION CT5SZG(CMOTBX,NRET)

	LOCAL AAREA   := GETAREA()
	LOCAL RETORNO := ""

	DBSELECTAREA("SZG")
	DBSETORDER(1)
	IF DBSEEK(XFILIAL()+CMOTBX)
		IF NRET == 4
			RETORNO := SZG->ZG_CONTA
		ELSEIF NRET == 2
			RETORNO := SZG->ZG_CONTABI
		ELSEIF NRET == 3
			RETORNO := .T.
		ELSEIF NRET == 5
			RETORNO := SZG->ZG_CONTAB	
		ELSEIF NRET == 7
			RETORNO :=SZG->ZG_CTAPDEB	
		ELSEIF NRET == 8
			RETORNO :=SZG->ZG_CTARDEB
		ENDIF
	ELSEIF NRET == 3
		RETORNO := .F.
	ENDIF

	RESTAREA(AAREA)

RETURN(RETORNO)
