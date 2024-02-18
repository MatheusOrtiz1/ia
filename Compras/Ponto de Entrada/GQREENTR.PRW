#include "RWMAKE.CH"

//ADICIONADO PARA TRATAR A FILIAL QUE ESTA GRAVANDO ERRADO NO TITULO
User Function GQREENTR()     
/*
LOCAL AAREA    := GETAREA()
LOCAL AAREA_SE2 := SE2->(GETAREA())
LOCAL AAREA_SA2 := SA2->(GETAREA())
Local	b	:= 25

// Posiciona no SA2 pra pegar dados que serão necessários pra gravar nos titulos
dbselectarea("SA2")
dbsetorder(1)
dbseek(xfilial("SA2")+SF1->F1_FORNECE+SF1->F1_LOJA)

// Posiciona no SE2 para ler os Titulos do Documento Entrada
dbselectarea("SE2")
DBSETORDER(6) //E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO
DBGOTOP()

IF lEN(SF1->F1_LOJA) == 3
	b:= 28
ENDIF

IF 	DBSEEK(XFILIAL("SE2")+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_PREFIXO+SF1->F1_DOC,.T.)
	WHILE SE2->E2_FILIAL+SE2->E2_NUM+SE2->E2_FORNECE == SF1->F1_FILIAL+SF1->F1_DOC+SF1->F1_FORNECE
		
		IF SE2->E2_LOJA <> SF1->F1_LOJA
			if !(SE2->E2_TIPO $ "TX/TXM/TXA/INS/CF-/CSS/IN-/IR-/IRF/ISS/SES/IS-/PI-")	//verifica se nao é um titulo de imposto
				RECLOCK("SE2",.F.)
				SE2->E2_LOJA  := SF1->F1_LOJA
				MSUNLOCK()
			ENDIF
			if (SE2->E2_TIPO $ "TX/TXM/TXA/INS/CF-/CSS/IN-/IR-/IRF/ISS/SES/IS-/PI-")	//verifica se nao é um titulo de imposto
				RECLOCK("SE2",.F.)
				SE2->E2_TITPAI  := SUBSTR(SE2->E2_TITPAI,1,b)+SF1->F1_LOJA //NFS000000124   NF 19156401
				MSUNLOCK()
			ENDIF
		ENDIF
		dbskip()
	enddo
	
ENDIF
RESTAREA(AAREA_SE2)
RESTAREA(AAREA_SA2)
RestArea(aArea)

*/
return nil
