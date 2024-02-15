//+-------+----------------+------------------------------------------------------------------------------------------------------------+
//| Autor | Luiz Fernando  | Data :  28.04.2023                                                                             
//+-------+--------+-------+------------------------------------------------------------------------------------------------------------+
//| Empresa        |                                                                                                     
//+----------------+--------------------------------------------------------------------------------------------------------------------+
//| Arquivo Fonte  | ReqContrato                                                                                                       
//+----------------+--------------------------------------------------------------------------------------------------------------------+
//| Funcao:        |                                                                                                                    
//+----------------+--------------------------------------------------------------------------------------------------------------------+
//|Parametros      |                                                                                                                    
//+----------------+--------------------------------------------------------------------------------------------------------------------+
//|Objetivo        | Preecnher                                                                                                                    
//|                |                                                                                                                    
//|                |                                                                                                                    
//|                |                                                                                                                    
//+----------------+--------------------------------------------------------------------------------------------------------------------+
#Include "Protheus.ch"

#DEFINE TIT_AVISO  "## Requisição Contrato ##"

Static Super_nOpc 
Static oModal, oDlgBrw, oCampos

Static cContrato, cRevisao, cTipo



User Function ReqContrato()
Local iBrw       := n 
Local BRW_CODPRO := aScan( aHeader, { |x| AllTrim( x[2] ) == "D1_COD" } )
Local BRW_REQCTL := aScan( aHeader, { |x| AllTrim( x[2] ) == "D1_REQCTRL" } )
Local BRW_VLRTOT := aScan( aHeader, { |x| AllTrim( x[2] ) == "D1_TOTAL" } )

Local aButtons   := { {"", "Salvar", { || fValidDlg() }, , , .T., .F.} }
Local ASizeFld   := {  TAMSX3("CN9_NUMERO")[1]  ,;  // 01-Contrato
                       TAMSX3("CN9_REVISA")[1]  ,;  // 02-Revisão
                       TAMSX3("CNP_CODIGO")[1]  ,;  // 03-Tipo
                       20                       ,;  // 04-Valor 
                       20                        }  // 05-Saldo Restante


//Local nValor     := 0.000


   Super_nOpc := 0
   oCampos    := Array( 04 )
   cContrato  := Space( ASizeFld[1] )
   cRevisao   := Space( ASizeFld[2] )
   cTipo      := Space( ASizeFld[3] )





   if !GDDeleted(iBrw) .And. !Empty( aCols[ iBrw, BRW_CODPRO])

      if Empty( aCols[ iBrw, BRW_VLRTOT] )
         MsgInfo("Atenção Necessário preecher ter válor total valido para esta operação.")
         Return( Nil )
      Endif

      // ### Carregado Dados ###
      if Valtype( AReqCtrl := StrToArray( aCols[ iBrw, BRW_REQCTL], ";" ) ) == "A"
         While Len(AReqCtrl) < 3 ; aAdd(AReqCtrl,"") ; End While 
         cContrato  := Padr( AReqCtrl[1], ASizeFld[1] )
         cRevisao   := Padr( AReqCtrl[2], ASizeFld[2] )
         cTipo      := Padr( AReqCtrl[3], ASizeFld[3] )
         //nValor     := Val(  AReqCtrl[4]  )
      Endif

      oModal:= FWDialogModal():New()       
      oModal:SetEscClose(.F.)
      oModal:setTitle( TIT_AVISO )
      //Seta a largura e altura da janela em pixel
      oModal:SetSize(120, 210)
 
      oModal:CreateDialog()
      oModal:addCloseButton(nil, "Fechar")
      oModal:addButtons(aButtons)
   
         //### Dialog
         oDlgBrw := TPanel():New( ,,, oModal:GetPanelMain() )
         oDlgBrw:Align := CONTROL_ALIGN_ALLCLIENT

         @ 03, 002 Say "Contrato"   Size 22, 08 Of oDlgBrw Pixel 
         @ 10, 002 MSGet oCampos[01] Var cContrato     F3 "CN9003" SIZE 68,10 PIXEL of oDlgBrw 

         @ 03, 072 Say "Revisão"    Size 40, 08 Of oDlgBrw Pixel 
         @ 10, 072 MSGet oCampos[02] Var cRevisao                  SIZE 20,10 PIXEL of oDlgBrw When .F.


         @ 03, 105 Say "Tipo"       Size 50, 08 Of oDlgBrw Pixel 
         @ 10, 105 MSGet oCampos[03] Var cTipo         F3 "CNP"    SIZE 20,10 PIXEL of oDlgBrw 

      oModal:Activate()
      
      // Gravando
      if Super_nOpc == 1
         aCols[ iBrw, BRW_REQCTL]  := Padr( cContrato, ASizeFld[1] ) + ";" + ;
                                      Padr( cRevisao , ASizeFld[2] ) + ";" + ;
                                      Padr( cTipo , ASizeFld[3] )    + ";" 
      Endif
      oCampos := Nil
   Else
      MsgAlert("Necessário selecionar item válido para esta operação.",TIT_AVISO)
   Endif 


Return( Nil )


//+------------------------------------------------------------------------------------------------------------------------------------------------------+
//|  
//+------------------------------------------------------------------------------------------------------------------------------------------------------+
Static Function fValidDlg()

   if Empty( cContrato )
      MsgAlert("Atenção necessário preeencher o Nro do Contrato", TIT_AVISO)
      Return( Nil )
   Endif    
   
   if Empty( cTipo )
      MsgAlert("Atenção necessário preeencher o Tipo desconto ", TIT_AVISO)
      Return( Nil )
   Endif

   Super_nOpc  := 1
   oModal:DeActivate()

Return( Nil )

