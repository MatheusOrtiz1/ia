#Include "Protheus.ch"

/*/{Protheus.doc} A140EXC
// Ponto de entrada utilizado pelo importador da ConexãoNF-e para limpar a variável __cInterNet e forçar 
a apresentação dos alertas customizados durante a importação.
@author ConexãoNF-e
@since 02/03/2022
@version 1.0
@return lRet, .T.
@see (https://atendimento.conexaonfe.com.br/kb/)
/*/
User Function A140EXC()
Local lRet := .T.

    // Ponto de chamada ConexãoNF-e sempre primeira instrução
    lRet := U_GTPE003()

    //If
    //    Regra existente
    //    [...]
    //EndIf

Return lRet
