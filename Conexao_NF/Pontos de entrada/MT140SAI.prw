#Include "Protheus.ch"

/*/{Protheus.doc} MT140SAI
// Ponto de entrada utilizado pelo importador da ConexãoNF-e para geração das ações do ERP sendo ela
a flag do ERP ao importar uma pré-nota, também atualiza a situação do XML ao 
excluir uma pré-nota, voltado o XML para pendente de importação.
@author ConexãoNF-e
@since 02/03/2022
@version 1.0
@return Nil, Nulo
@see (https://atendimento.conexaonfe.com.br/kb/)
/*/
User Function MT140SAI()

    // Ponto de chamada ConexãoNF-e sempre como primeira instrução 
    U_GTPE016()

    //If
    //    Regra existente
    //    [...]
    //EndIf

Return Nil 
