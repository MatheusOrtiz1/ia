#include "rwmake.ch"
#INCLUDE "TOPCONN.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RETNUMCAD ºAutor  ³Paulo Pego          º Data ³  10/09/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retorna o proximo numero de Cliente/Forncedores            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametro ³ cTIPO =  SA1 - Cadastro Clientes                           º±±
±±º          ³          EX1 - Cadastro Clientes Exportacao                º±±
±±º          ³          SA2 - Cadastro de Fonecedores                     º±±
±±º          ³          EX2 - Cadastro Fornecedores Expotacao             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ cRET - Codigo do proximo Numero a ser utilizado            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Utilizado Soluvel/Embalagem/Alimentos/RH                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function RETNUMCAD(cTIPO)
Local aAREA := GetArea(), aSA1 := SA1->(GetArea()), aSA2 := SA2->(GetArea())

If !inclui
   If cTIPO $ "SA1/EX1"
      Return SA1->A1_COD
   Else
      Return SA2->A2_COD
   Endif
Endif

Do While .T.
   cRET := MyProxNum(cTIPO)

   If cTIPO $ "SA1/EX1"
      SA1->( DbSetOrder(1) )
      If !SA1->( DbSeek( xFilial("SA1") + cRET ))  
         Exit 
      Endif
   Else   
      SA2->( DbSetOrder(1) )
      If !SA2->( DbSeek( xFilial("SA2") + cRET ))  
         Exit 
      Endif
   Endif               

EndDo

 
SA1->(RestArea(aSA1))
SA2->(RestArea(aSA2))

RestArea(aAREA)
Return cRET

//---------------------------------------------------------------------------------------------------------------//
Static Function MyProxNum(cTIPO)

DbSelectArea("Z00")
If !DbSeek(xFilial("Z00")+cTIPO)
   RecLock("Z00",.T.)
   Z00->Z00_ALIAS := cTIPO
   Z00->Z00_COD   := "000000"
   MsUnlock("Z00")
Endif   

RecLock("Z00",.F.)
cRET         := SOMA1(Z00->Z00_COD)
Z00->Z00_COD := cRET
MsUnlock("Z00")


Return cRET
