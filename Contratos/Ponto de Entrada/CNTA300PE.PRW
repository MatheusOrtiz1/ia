
#INCLUDE "PROTHEUS.CH"

User Function CNTA300()

Local aParam     := PARAMIXB
Local xRet       := .T.
Local oObj       := ''
Local cIdPonto   := ''
Local cIdModel   := ''
Local lIsGrid    := .F.

If aParam <> NIL 
       oObj       := aParam[1]
         
       cIdPonto   := aParam[2]
       cIdModel   := aParam[3]
       lIsGrid    := ( Len( aParam ) > 3 )

        /*
        ElseIf cIdPonto == 'BUTTONBAR'
ApMsgInfo('Adicionando Botao na Barra de Botoes (BUTTONBAR).' + CRLF + 'ID ' + cIdModel )
xRet := { {'Salvar', 'SALVAR', { || Alert( 'Salvou' ) }, 'Este botao Salva' } }
            
       EndIf
        */
        If cIdPonto == 'FORMPOS'
                 
                If Alltrim (cIdModel) == 'CNADETAIL'
                    
                     IF Alltrim(FwFldGet("CN9_FLGREJ")) == '1' .And. Alltrim(FwFldGet("CNA_FLREAJ")) == '2'
                         MSGINFO( "O Campo de Reajuste, deve estar como ( SIM ) na planilha","PLANILHA CAMPO DE REAJUSTE" )
                         xRet := .F.
                    ENDIF                        
                    
                    IF Alltrim(FwFldGet("CN9_FLGREJ")) == '1'
                      If Empty(FwFldGet("CNA_INDICE")) .Or.  Empty(FwFldGet("CNA_UNPERI")) .Or. Empty(FwFldGet("CNA_PERI")) .Or. Empty(FwFldGet("CNA_MODORJ"))  .Or. Empty(FwFldGet("CNA_PROXRJ")) 
                        MSGINFO( "Verifique todos os campos de reajuste de Indice na Planilha", "Campos Obrigatorios do Indice" )
                        xRet := .F.
                       EndIf  
                    EndIf   
                Endif 

                
                If Alltrim (cIdModel) == 'CN9MASTER'
                
                    IF Alltrim(FwFldGet("CN9_FLGREJ")) == '1' .And. Alltrim(FwFldGet("CNA_FLREAJ")) == '2'
                         MSGINFO( "O Campo de Reajuste, deve estar como ( SIM ) na planilha","PLANILHA CAMPO DE REAJUSTE" )
                         xRet := .F.
                    ENDIF                       
                    
                    IF Alltrim(FwFldGet("CN9_FLGREJ")) == '1'
                      If Empty(FwFldGet("CNA_INDICE")) .Or.  Empty(FwFldGet("CNA_UNPERI")) .Or. Empty(FwFldGet("CNA_PERI")) .Or. Empty(FwFldGet("CNA_MODORJ"))  .Or. Empty(FwFldGet("CNA_PROXRJ")) 
                        MSGINFO( "Verifique todos os campos de reajuste de Indice na Planilha", "Campos Obrigatorios do Indice" )
                        xRet := .F.
                       EndIf  
                    EndIf  
                Endif  
        ElseIf cIdPonto == 'BUTTONBAR'
              
              xRet := { {'Produtos Contrato Aberto', 'Produtos Contrato Aberto', { || u_CADZA4(FwFldGet("CN9_NUMERO")) }, 'Produtos de Contrato Aberto' } }    
                      
        EndIf

EndIf

Return xRet
