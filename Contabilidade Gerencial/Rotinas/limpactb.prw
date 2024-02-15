#include "rwmake.ch"
#include "topconn.ch"
 
User Function LimpaCtb()
Local cPerg:="X_CTB", _sAlias := Alias(), aRegs:={}
dbSelectArea("SX1")
dbSetOrder(1)
dbGoTop()
cPerg := PADR(cPerg,6)
AADD(aRegs,{cPerg,"01","Modulo      ?","Espanhol","Ingles","mv_ch1","N",1,0,0,"C","","mv_par01","Compras  ","","","","","Faturamento  ","","","","","Financeiro","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"02","Data de     ?","Espanhol","Ingles","mv_ch2","D",8,0,0,"G","","mv_par02","","","","'"+DTOC(dDataBase)+"'","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"03","Data ate    ?","Espanhol","Ingles","mv_ch3","D",8,0,0,"G","","mv_par03","","","","'"+DTOC(dDataBase)+"'","","","","","","","","","","","","","","","","","","","","","",""})
//AADD(aRegs,{cPerg,"04","Apaga Lote  ?","Espanhol","Ingles","mv_ch4","N",1,0,0,"C","","mv_par04","Sim      ","","","","","Nao  ","","","","","","","","","","","","","","","","","","","",""})
 
If !dbSeek(cPerg,.T.)
   For i:=1 to Len(aRegs)    
       RecLock("SX1",.T.)
       For j:=1 to FCount()
          If j <= Len(aRegs[i])
             FieldPut(j,aRegs[i,j])
          Endif
       Next
       MsUnlock()
       dbCommit()
   Next
EndIf   
dbSelectArea(_sAlias)
 
If Pergunte(cPerg,.t.)
 aFrase := {}
 aErros := {}
 cApaga := ""
 Do Case
  Case mv_par01 == 1
   // COMPRAS
   AADD(aFrase,"UPDATE "+RetSqlName("SF1")+" SET F1_DTLANC = '' WHERE F1_DTDIGIT BETWEEN '"+Dtos(mv_par02)+"' AND '"+Dtos(mv_par03)+"' AND F1_FILIAL = '" + xFilial("SF1") + "'")
   cApaga := "UPDATE "+RetSqlName("CT2")+" SET D_E_L_E_T_ = '*' WHERE CT2_LOTE LIKE '%8810%' AND CT2_DATA BETWEEN '"+Dtos(mv_par02)+"' AND '"+Dtos(mv_par03)+"' AND CT2_FILIAL = '" + xFilial("CT2") + "'"
  Case mv_par01 == 2
     //FATURAMENTO
     AADD(aFrase,"UPDATE "+RetSqlName("SF2")+" SET F2_DTLANC = '' WHERE F2_EMISSAO BETWEEN '"+Dtos(mv_par02)+"' AND '"+Dtos(mv_par03)+"' AND F2_FILIAL = '" + xFilial("SF2") + "'" )
     cApaga := "UPDATE "+RetSqlName("CT2")+" SET D_E_L_E_T_ = '*' WHERE CT2_LOTE LIKE '%8820%' AND CT2_DATA BETWEEN '"+Dtos(mv_par02)+"' AND '"+Dtos(mv_par03)+"' AND CT2_FILIAL = '" + xFilial("CT2") + "'"
  Case mv_par01 == 3                       
   // FINANCEIRO
   AADD(aFrase,"UPDATE "+RetSqlName("SE1")+" SET E1_LA = ''             WHERE E1_EMISSAO BETWEEN '"+Dtos(mv_par02)+"' AND '"+Dtos(mv_par03)+"' AND E1_FILIAL = '" + xFilial("SE1") + "' AND SUBSTRING(E1_ORIGEM,1,3)='FIN' " )
   AADD(aFrase,"UPDATE "+RetSqlName("SE5")+" SET E5_LA = '', E5_LOTE='' WHERE E5_DATA    BETWEEN '"+Dtos(mv_par02)+"' AND '"+Dtos(mv_par03)+"' AND E5_FILIAL = '" + xFilial("SE5") + "'" )
   AADD(aFrase,"UPDATE "+RetSqlName("SE2")+" SET E2_LA = '' WHERE E2_EMIS1   BETWEEN '"+Dtos(mv_par02)+"' AND '"+Dtos(mv_par03)+"' AND E2_FILIAL = '" + xFilial("SE2") + "' AND SUBSTRING(E2_ORIGEM,1,3)='FIN' "  )
   AADD(aFrase,"UPDATE "+RetSqlName("SEF")+" SET EF_LA = ''             WHERE EF_DATA    BETWEEN '"+Dtos(mv_par02)+"' AND '"+Dtos(mv_par03)+"' AND EF_FILIAL = '" + xFilial("SEF") + "'" )
     cApaga := "UPDATE "+RetSqlName("CT2")+" SET D_E_L_E_T_ = '*' WHERE CT2_LOTE LIKE '%8850%' AND CT2_DATA BETWEEN '"+Dtos(mv_par02)+"' AND '"+Dtos(mv_par03)+"' AND CT2_FILIAL = '" + xFilial("CT2") + "'"
 EndCase
 For i := 1 To len(aFrase)
  //  U_SHOWSTRING(aFrase[i])
  nResult := TCSQLEXEC(aFrase[i])
  If nResult <> 0
   cErro   := " Erro:"+TCSqlError()
   AADD(aErros,cErro)
  Else
   cErro := ""
  EndIf
  
 Next
 
  // If mv_par04 == 1
  nResult := TCSQLEXEC(cApaga)
  If nResult <> 0
   cErro   := " Erro:"+TCSqlError()
   AADD(aErros,cErro)
  Else
   cErro := ""
  EndIf
  
  // EndIf
 
 If nResult == 0
  MsgInfo("Comando Executado com Sucesso! Executar Reprocessamento! ")
 Else
  If Len(aErros)>0     
      cLog := ""
      For ix := 1 to Len(aErros)
          cLog += (aErros[ix]+chr(10)+chr(13))
      Next
   @ 116,090 To 416,707 Dialog oDlgMemo Title "Ocorrencias"
   @ 001,005 Get cLog   Size 300,120  MEMO                 Object  oMemo
   @ 137,10+5*50 Button OemToAnsi("_Fechar")   Size 35,14 Action Close(oDlgMemo)
   Activate Dialog oDlgMemo
  EndIf
  
  MsgInfo("Falha no Comando! Retorno "+Str(nResult)+cErro )
  
 EndIf
 
EndIf
 
Return nil





