#Include "Protheus.ch"

/*/{Protheus.doc} A103CND2
// Ponto de entrada utilizado pelo importador da ConexãoNF-e para alterar a condição de pagamento 
na importação do CTe em lote.
@author ConexãoNF-e
@since 02/03/2022
@version 1.0
@return aDuplic, Array com a nova condição de pagamento 
@see (https://atendimento.conexaonfe.com.br/kb/)
/*/
User Function A103CND2()
Local aDuplic := PARAMIXB

    //If
    //    Regra existente
    //    [...]
    //EndIf

    // Ponto de chamada ConexãoNF-e sempre como última instrução.
    aDuplic := U_GTPE001()
    
Return aDuplic
