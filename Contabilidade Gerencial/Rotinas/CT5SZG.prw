/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CT5SZG    �Autor  �Microsiga           � Data �  05/02/2010 ���
�������������������������������������������������������������������������͹��
���Desc.     � Programa para posicionamento no cadastro de "Contabilizacao���
���          � motivo de baixa" e retorno de campos.                      ���
���          �                                                            ���
���          � Parametros:                                                ���
���          � CMOTBX Motivo da baixa                                     ���
���          � NRET   Tipo do retorno                                     ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Disponibilizado por Helena Shigueoka                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
