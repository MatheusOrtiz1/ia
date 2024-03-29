#Include 'Protheus.ch'
/*
�����������������������������������������������������������������������������
���Programa  � MTA131C8    �Autor Everton Forti		 � Data � 06/03/2023  ���
�������������������������������������������������������������������������͹��
���Descri��o: utilizado para acrescentar informa��es na gera��o da cota��o���
�������������������������������������������������������������������������͹��
*/
User Function MTA131C8()

Local oModFor := PARAMIXB[1]
Local MVITMCLVL := SUPERGETMV("MV_ITMCLVL")

//Customiza��es do usuario
oModFor:LoadValue("C8_UCC",SC1->C1_CC)
oModFor:LoadValue("C8_UCO",SC1->C1_CO)

IF MVITMCLVL == "1"
    oModFor:LoadValue("C8_CLVL",SC1->C1_CLVL)
    oModFor:LoadValue("C8_UITEM",SC1->C1_ITEMCTA)
ENDIF

Return
