//�����������������������������������������������������������������������Ŀ
//�Ponto de Entrada  � TMKGRSP  � Autor �Everton Forti	� Data �27/02/2015�
//�����������������������������������������������������������������������Ĵ
//�Descri��o � Campos do SUSPECT para PROSPECT                          �
//�����������������������������������������������������������������������Ĵ
//�����������������������������������������������������������������������Ĵ
//�USO��o � CONASA  - SIGATMK					                          �
//�����������������������������������������������������������������������Ĵ
User Function TMKGRSP()                  
	//Alert("Copiada Observa��o Suspect para o Prospect")
	SUS->(recLock("SUS", .f.))
	SUS->US_OBS 	:= ACH->ACH_OBS
	SUS->US_VEND	:= ACH->ACH_VEND
	SUS->US_UDTINC	:= DDATABASE  
	SUS->(msUnlock())
 Return 