#Include 'Protheus.ch'
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³ MTA131C8    ºAutor Everton Forti		 º Data ³ 06/03/2023  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescrição: utilizado para acrescentar informações na geração da cotação¹±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
*/
User Function MTA131C8()

Local oModFor := PARAMIXB[1]
Local MVITMCLVL := SUPERGETMV("MV_ITMCLVL")

//Customizações do usuario
oModFor:LoadValue("C8_UCC",SC1->C1_CC)
oModFor:LoadValue("C8_UCO",SC1->C1_CO)

IF MVITMCLVL == "1"
    oModFor:LoadValue("C8_CLVL",SC1->C1_CLVL)
    oModFor:LoadValue("C8_UITEM",SC1->C1_ITEMCTA)
ENDIF

Return
