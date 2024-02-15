#INCLUDE "PROTHEUS.CH"


User Function SBMTOSB1()



dbSelectArea('SB1')
dbSetOrder(1)   
DBGOTOP()

	While !SB1->(Eof())
	
		IF EMPTY(SB1->B1_CONTA)
			dbSelectArea('SBM')
			dbSetOrder(1)   
			IF DBSEEK(xFILIAL("SBM")+SB1->B1_GRUPO)
				RECLOCK("SB1",.F.)		
				SB1->B1_CONTA := SBM->BM_UCCTB
				MSUNLOCK()
			ENDIF
		ENDIF

	DBSKIP()
	ENDDO

Return()

