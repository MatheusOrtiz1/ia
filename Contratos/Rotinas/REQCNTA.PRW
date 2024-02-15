//+-------+----------------+------------------------------------------------------------------------------------------------------------+
//| Autor | Luiz Fernando  | Data : 15.06.2023                                                                            
//+-------+--------+-------+------------------------------------------------------------------------------------------------------------+
//| Empresa        | GForti                                                                                                    
//+----------------+--------------------------------------------------------------------------------------------------------------------+
//| Arquivo Fonte  | REQCNTA                                                                                                       
//+----------------+--------------------------------------------------------------------------------------------------------------------+
//| Funcao:        | Localizar os contrato SD1. para trazer os Desconto                                                                                                                    
//+----------------+--------------------------------------------------------------------------------------------------------------------+
//|Parametros      |                                                                                                                    
//+----------------+--------------------------------------------------------------------------------------------------------------------+
//|Objetivo        |                                                                                                                    
//|                |                                                                                                                    
//|                |                                                                                                                    
//|                |                                                                                                                    
//+----------------+--------------------------------------------------------------------------------------------------------------------+
#Include "Protheus.ch"
#Include "FWMVCDEF.CH"

User Function REQCNTA()
Local cQuery, cField
Local iAchou


   if !( FunName() $ "CNTA121" ) ; Return( Nil ) ; Endif

   //#####COMMAND
   if Type("Super_AReqIt" ) == "U"  //Definindo que a Variavel Não Existe 
      Return( Nil )
   Endif 

   cField := "SD1.D1_DOC + ' - ' + SD1.D1_SERIE + ' - ' + SD1.D1_FORNECE + ' - ' + SD1.D1_LOJA AS D1KEY ,
	cField += "SUBSTRING(SD1.D1_REQCTRL,21,4) AS TIPOCTRL," 
	cField += "SUM(SD1.D1_TOTAL - SD1.D1_REQTOT) AS REQSALDO "

   cQuery := "SELECT " + cField + " FROM " + RetSQLName("SD1") + " SD1 "
   cQuery += "WHERE SD1.D1_FILIAL = '" + xFilial("SD1") + "' AND SD1.D_E_L_E_T_ <> '*' "
   cQuery += "AND SUBSTRING(SD1.D1_REQCTRL,1,15) = '" + m->CND_CONTRA + "' "
   cQuery += "AND (SD1.D1_TOTAL - SD1.D1_REQTOT) > 0  "
   cQuery += "GROUP BY D1_DOC + ' - ' + D1_SERIE + ' - ' + D1_FORNECE + ' - ' + D1_LOJA , SUBSTRING(SD1.D1_REQCTRL,21,4) "
   cQuery := ChangeQuery(cQuery)
   DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "tReqSld", .T., .T.)
   if !Empty( tReqSld->D1KEY ) 
      //## Criando Array na Variavel [Public], que quando salvar Medição é pra 
      tReqSld->(DbEVal({||   aAdd(Super_AReqIt, { tReqSld->D1KEY, tReqSld->TIPOCTRL, tReqSld->REQSALDO } )    }))
   Endif 
   tReqSld->(DbCloseArea())


   if Len( Super_AReqIt ) > 0 
      //Super_oModel:SetOperation(MODEL_OPERATION_INSERT)
      Super_oModel:SetValue("CXNDETAIL","CXN_CHECK"     , .T.)  // ##Marcar a planilha(nesse caso apenas uma)
      Super_oModel:GetModel('CNEDETAIL'):GoLine(1)
     // Super_oModel:GetModel('CNEDETAIL'):Length()  // Qtde Linhas

      For iAchou := 1 TO Len( Super_AReqIt )
         Super_oModel:GetModel('CNQDETAIL'):GoLine( iAchou )

         Super_oModel:SetValue("CNQDETAIL","CNQ_D1KEY"     ,Super_AReqIt[iAchou, 01 ] )
         Super_oModel:SetValue("CNQDETAIL","CNQ_TPDESC"    ,Super_AReqIt[iAchou, 02 ] )
         Super_oModel:SetValue("CNQDETAIL","CNQ_VALOR"     ,Super_AReqIt[iAchou, 03 ] )
        
        if iAchou < Len( Super_AReqIt )
            Super_oModel:GetModel('CNQDETAIL'):AddLine()
        Endif
      Next iAchou
      Super_oModel:CommitData()
   Endif
   
Return( Nil )


