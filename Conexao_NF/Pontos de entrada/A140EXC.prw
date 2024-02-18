#Include "Protheus.ch"

/*/{Protheus.doc} A140EXC
// Ponto de entrada utilizado pelo importador da Conex�oNF-e para limpar a vari�vel __cInterNet e for�ar 
a apresenta��o dos alertas customizados durante a importa��o.
@author Conex�oNF-e
@since 02/03/2022
@version 1.0
@return lRet, .T.
@see (https://atendimento.conexaonfe.com.br/kb/)
/*/
User Function A140EXC()
Local lRet := .T.

    // Ponto de chamada Conex�oNF-e sempre primeira instru��o
    lRet := U_GTPE003()

    //If
    //    Regra existente
    //    [...]
    //EndIf

Return lRet
