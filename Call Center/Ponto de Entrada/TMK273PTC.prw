//�����������������������������������������������������������������������Ŀ
//�Ponto de Entrada  � TMK273PTC � Autor �Everton Forti	� Data �27/02/2015�
//�����������������������������������������������������������������������Ĵ
//�Descri��o � Campos do PROSPECT para CLIENTE                           �
//�����������������������������������������������������������������������Ĵ
//�USO��o � CONASA  - SIGATMK					                         �
//�����������������������������������������������������������������������Ĵ
User Function TMK273PTC()


//Alert("Copiada Observa��o Prospect para o Cliente")
    
If Reclock("SA1",.F.)   
SA1->A1_OBSERV	:= SUS->US_OBS
SA1->A1_VEND    := SUS->US_VEND 
SA1->A1_UDTINC  := DDATABASE
Msunlock()
EndIf


Return 