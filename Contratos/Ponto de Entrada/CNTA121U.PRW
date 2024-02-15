#Include "Protheus.ch"
#Include "FWMVCDEF.CH"

//+-------+----------------+------------------------------------------------------------------------------------------------------------+
//| Autor | ADRIANO GUEDES  | Data :28/04/2023                                                                            
//+-------+--------+-------+------------------------------------------------------------------------------------------------------------+
//| Empresa        |                                                                                                     
//+----------------+--------------------------------------------------------------------------------------------------------------------+
//| Arquivo Fonte  | CNTA121.PRW                                                                                                       
//+----------------+--------------------------------------------------------------------------------------------------------------------+
//| Funcao:        |        P.E. Medicaso de contratos                                                                                                            
//+----------------+--------------------------------------------------------------------------------------------------------------------+
//|Parametros      |                                                                                                                    
//+----------------+--------------------------------------------------------------------------------------------------------------------+
//|Objetivo        |                                                                                                                    
//|                |                                                                                                                    
//|                |                                                                                                                    
//|                |                                                                                                                    
//+----------------+--------------------------------------------------------------------------------------------------------------------+



User Function CNTA121()

Local aParam    := PARAMIXB
Local xRet      := .T.

Local oModel
Local cIdPonto,  cIdModel
Local iL
Local cChaveCR1
Local cChaveCR2
Local cObsCN9 := ""

   If aParam != Nil 
      cIdPonto := AllTrim(aParam[2])
      cIdModel := aParam[3]       
      
      
      //FORMCOMMITTTSPOS: Após a gravação da tabela do formulário. Equivalente ao CN130PGRV
      If ( cIdPonto == "FORMCOMMITTTSPOS" .And. cIdModel == "CNDMASTER")
         if Valtype( oModel := aParam[1] ) == "O"
            if oModel:GetOperation() == MODEL_OPERATION_INSERT
               For iL := 1 To Super_oModel:GetModel('CNQDETAIL'):Length() 
                  Super_oModel:GetModel('CNQDETAIL'):GoLine( iL )
                  if Super_oModel:GetModel('CNQDETAIL'):isDeleted()
                     Loop
                  Endif

                  // Gravando na SD1
                  cField := "SD1.R_E_C_N_O_ AS IRECNO , (SD1.D1_TOTAL - SD1.D1_REQTOT) AS REQTOT, SD1.D1_REQCTRL"
                  
                  cQuery := "SELECT " + cField + " FROM " + RetSQLName("SD1") + " SD1 "
                  cQuery += "WHERE SD1.D1_FILIAL = '" + xFilial("SD1") + "' AND SD1.D_E_L_E_T_ <> '*' "
                  cQuery += "AND SUBSTRING(SD1.D1_REQCTRL,1,15) = '" + m->CND_CONTRA + "' "
                  cQuery += "AND SD1.D1_DOC + ' - ' + SD1.D1_SERIE + ' - ' + SD1.D1_FORNECE + ' - ' + SD1.D1_LOJA  = '" + Super_oModel:GetModel('CNQDETAIL'):getvalue('CNQ_D1KEY') + "'"
                  DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "tReqSD1", .T., .T.)
                  While tReqSD1->(!Eof())
                     if !Empty( tReqSD1->IRECNO )
                        SD1->(DbGoto( tReqSD1->IRECNO ) )
                        SD1->(RecLock("SD1",.F.))
                        SD1->D1_REQCTRL := Left( tReqSD1->D1_REQCTRL,25) + ";" + Alltrim( m->CND_NUMMED )
                        SD1->D1_REQTOT  += Super_oModel:GetModel('CNQDETAIL'):getvalue('CNQ_VALOR')
                        MsUnLock()
                     Endif 
                     tReqSD1->(DbSkip())
                  End While
                  tReqSD1->(DbCloseArea())
               
               Next iL

               // Ajuste de dados e campos para a Alçada de Aprovação SCR
               If SCR->CR_FILIAL == CND->CND_FILIAL .And. SCR->CR_TIPO == 'IM' .And. Substr(SCR->CR_NUM,1,6) == CND->CND_NUMMED    
                    
                  cObsCN9 := CN9->CN9_XHISTO
                  // GRAVA DADOS DA OBSERVACAO DO COTNRATO NA MEDICAO
                  RECLOCK( "CND", .F. )
                    CND->CND_OBS :=  cObsCN9
                  CND->(MSUNLOCK())   
                  
                  // GERA CHAVE DE CONSULTA
                  cChaveCR1 := SCR->(CR_FILIAL+CR_TIPO+Substr(CR_NUM,1,6))
                  cChaveCR2 := cChaveCR1+'000001001'
               
                  DbSelectArea("SCR")
                  DbSetOrder(1)
                  // grava os dados da medicao ou contrato na tela de aprovação SCR
                  If SCR->(DbSeek(cChaveCR2))
                     While !SCR->(EOF()) .And. SCR->(CR_FILIAL+CR_TIPO+Substr(CR_NUM,1,6)) == cChaveCR1
                        RECLOCK( "SCR", .F. )
                           SCR->CR_OBS := cObsCN9
                        SCR->(MSUNLOCK()) 
                     
                        SCR->(DBSKIP())  
                     EndDo
                  EndIf
               EndIf    

            Elseif oModel:GetOperation() == MODEL_OPERATION_DELETE
 
               For iL := 1 To Super_oModel:GetModel('CNQDETAIL'):Length() 
                  Super_oModel:GetModel('CNQDETAIL'):GoLine( iL )
                  // Gravando na SD1
                  cField := "SD1.R_E_C_N_O_ AS IRECNO , (SD1.D1_TOTAL - SD1.D1_REQTOT) AS REQTOT,  SD1.D1_REQCTRL"
                  
                  cQuery := "SELECT " + cField + " FROM " + RetSQLName("SD1") + " SD1 "
                  cQuery += "WHERE SD1.D1_FILIAL = '" + xFilial("SD1") + "' AND SD1.D_E_L_E_T_ <> '*' "
                  cQuery += "AND SUBSTRING(SD1.D1_REQCTRL,1,15) = '" + m->CND_CONTRA + "' "
                  cQuery += "AND SD1.D1_DOC + ' - ' + SD1.D1_SERIE + ' - ' + SD1.D1_FORNECE + ' - ' + SD1.D1_LOJA  = '" + Super_oModel:GetModel('CNQDETAIL'):getvalue('CNQ_D1KEY') + "'"
                  DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "tReqSD1", .T., .T.)
                  While tReqSD1->(!Eof())
                     if !Empty( tReqSD1->IRECNO )
                        SD1->(DbGoto( tReqSD1->IRECNO ) )
                        SD1->(RecLock("SD1",.F.))
                        SD1->D1_REQCTRL := Left( tReqSD1->D1_REQCTRL,25) 
                        SD1->D1_REQTOT  -= Super_oModel:GetModel('CNQDETAIL'):Getvalue('CNQ_VALOR')
                        MsUnLock()
                     Endif 
                     tReqSD1->(DbSkip())
                  End While
                  tReqSD1->(DbCloseArea())
               
               Next iL



            Endif 
         EndIf     
      
      //### Opção Alterar Descontos.. [ENTER]
      Elseif cIdPonto == "FORMLINEPRE" .And. cIdModel == "CNQDETAIL"
         if Len(aParam) >= 6  // Verificando o Enter
            if aParam[6] == "CNQ_D1KEY" .And.  aParam[5] == "CANSETVALUE" 
               xRet := .F.
            Elseif (aParam[6] == "CNQ_VALOR" .or. aParam[6] == "CNQ_TPDESC" ) .And.  aParam[5] == "CANSETVALUE" 
               xRet := Empty( Super_oModel:GetValue("CNQDETAIL","CNQ_D1KEY") )
            Endif
         Endif
      EndIf     
   Endif   



Return( xRet )
