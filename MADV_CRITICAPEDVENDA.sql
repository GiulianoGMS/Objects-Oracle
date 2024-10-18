-- Criar a inconsistência na CONSINCO.MAD_CRITICAPEDCONFIG 
-- Inserir o select em MADV_CRITICAPEDVENDA

CREATE OR REPLACE VIEW CONSINCO.MADV_CRITICAPEDVENDA AS
select  /*+rule*/
       a.nropedvenda, a.nroempresa, 'Valor Minimo' codcritica
from   consinco.madv_pedvenda a, consinco.mad_parametro b
where  a.situacaoped = 'L'
and    a.vlrpedido   < b.vlrminimopedido
and    a.nroempresa  = b.nroempresa
And    a.codgeraloper not in (807, 806, 918, 917)

union

select a.nropedvenda, a.nroempresa, 'Markup'
from   consinco.madv_pedbasemarkup a
where  a.vlratendido < a.vlrcustoatendido


union

 select distinct a.nropedvenda, a.nroempresa, 'CGO 806 Somente Consumo' codcritica
   from consinco.mad_pedvendaitem a, consinco.mrl_lanctoestoque b, consinco.mad_pedvenda c
 where a.seqmovtoestq = b.seqmovtoestq
   and a.seqproduto = b.seqproduto
   and a.nropedvenda = c.nropedvenda
   and a.nroempresa = c.nroempresa
   and a.nroempresa = b.nroempresa
   and b.nroempresa = c.nroempresa
   and b.codgeraloper in (20,30,35,46,47,62,63,34)
   and c.codgeraloper not in (807,918,919)
   and c.tippedido = 'X'
   and c.situacaoped not in ('F', 'C')

   union all

   select distinct a.nropedvenda, a.nroempresa, 'CGO 807 Somente Perdas' codcritica
  from consinco.mad_pedvendaitem a, consinco.mrl_lanctoestoque b, consinco.mad_pedvenda c
 where a.seqmovtoestq = b.seqmovtoestq
   and a.seqproduto = b.seqproduto
   and a.nropedvenda = c.nropedvenda
   and a.nroempresa = c.nroempresa
   and a.nroempresa = b.nroempresa
   and b.nroempresa = c.nroempresa
   and b.codgeraloper in (21,24,25,33,41,90,91)
   and c.codgeraloper not in(806)
   and c.tippedido = 'X'
   and c.situacaoped not in ('F', 'C')

  union all

    select A.nropedvenda, A.nroempresa,'CGO USO EXC.LJ C/ FILIAL' codcritica
   from consinco.mad_pedvenda a
   where a.codgeraloper in (135,45,44,57,94,801,850,64,102)
   and a.situacaoped not in ('C','F')
   and a.nroempresa in (1,9,10,11,12,13,15,21,22,24,29,36,500,504,505,600,601,602)

   union all

   select A.nropedvenda, A.nroempresa,'CGO NAO PERM. CNPJ BASE IGUAIS' codcritica
   from consinco.mad_pedvenda a, consinco.ge_pessoa b
   where a.seqpessoa = b.seqpessoa
   and a.situacaoped not in ('C','F')
   and a.codgeraloper in (95,93)
   and exists ( select * from consinco.mad_pedvenda c, consinco.max_empresa d
                where a.nropedvenda = c.nropedvenda
                and c.nroempresa = d.nroempresa
                and substr((lpad(b.nrocgccpf,13,0)),0,9)= substr((lpad(d.nrocgc,13,0)),0,9))

   union all

  --- Adicionado por Cipolla em 30/12/2021 a pedido da Neides/Paulinho
   select A.nropedvenda, A.nroempresa,'CGO NAO PERM CNPJ BASE DIFEREN' codcritica
   from consinco.mad_pedvenda a, consinco.ge_pessoa b
   where a.seqpessoa = b.seqpessoa
   and a.situacaoped not in ('C','F')
   and a.codgeraloper in (850)
   and exists ( select * from consinco.mad_pedvenda c, consinco.max_empresa d
                where a.nropedvenda = c.nropedvenda
                and c.nroempresa = d.nroempresa
                and substr((lpad(b.nrocgccpf,12,0)),0,8) != substr((lpad(d.nrocgc,12,0)),0,8))

  union all

  select A.nropedvenda, A.nroempresa,'CGO INVALIDO P/ A LOJA' codcritica
   from consinco.mad_pedvenda a, consinco.ge_pessoa b
   where a.seqpessoa = b.seqpessoa
   and a.situacaoped not in ('C','F')
   and a.codgeraloper in (806,807,918, 919)
   and exists ( select * from consinco.mad_pedvenda c, consinco.max_empresa d
                where a.nropedvenda = c.nropedvenda
                and c.nroempresa = d.nroempresa
                and lpad(b.nrocgccpf,13,0)!= lpad(d.nrocgc,13,0))


   union all

    select c.nropedvenda, c.nroempresa,'CGO NAO PERMITIDO RAZAO IGUAL' codcritica
   from consinco.mad_pedvenda c,consinco.ge_pessoa d, consinco.max_empresa e, (select substr((lpad(a.nrocgccpf,13,0)),0,9)as raiz,b.seqpessoaemp,a.fantasia, b.nroempresa
from consinco.ge_pessoa a, consinco.max_empresa b
where a.seqpessoa = b.seqpessoaemp) f, consinco.max_codgeraloper g
 where c.nroempresa = e.nroempresa
   and c.seqpessoa = d.seqpessoa
   and c.nroempresa = f.nroempresa
   and c.codgeraloper = g.codgeraloper
   and substr((lpad(d.nrocgccpf,13,0)),0,9) = f.raiz
   and g.cfopestado in (5405,5102,6404,1202,1411,5411,5202,5929,5551,6102)
   ---and b.codgeraloper in (95)
   --and c.codgeraloper != 807
  -- and c.tippedido = 'X'
  -- and c.nropedvenda in (155703,327742)
   and c.situacaoped not in ('F', 'C')

   union all

     ---Criticar itens que est?o abaixo de 10g, para evitar faturamento indevido - Solicitac?o de Inclus?a Leonardo/Thome. Incluido por Cipolla 31/07/2022 - Apenas segmento E-commerce
   select distinct A.nropedvenda, A.nroempresa,'QTDE INFERIOR A 10G -VERIFICAR' codcritica
   from consinco.mad_pedvenda a
   where exists ( select 1 from  consinco.mad_pedvendaitem b where a.nropedvenda = b.nropedvenda and A.NROEMPRESA = B.NROEMPRESA and b.qtdpedida <= '0.010')
   and a.nrosegmento = 5
   and a.situacaoped not in ('C','F')

UNION ALL -- Giuliano - Solicitac?o Neides Ticket 104571 - 01/10/2022

/* Bloqueia Forma Pagto Mesma Raz?o para emiss?es entre CNPJs raizes distintos */

SELECT DISTINCT A.NROPEDVENDA, A.NROEMPRESA, 'VERIFICAR FORMA PAGTO' CODCRITICA
   FROM CONSINCO.MAD_PEDVENDA A LEFT JOIN CONSINCO.MRL_FORMAPAGTO DD ON A.NROFORMAPAGTO = DD.NROFORMAPAGTO
   WHERE DD.NROFORMAPAGTO = 99
   AND (SELECT DISTINCT SUBSTR(LPAD(NROCGCCPF,12,0),1,8) FROM CONSINCO.GE_PESSOA WHERE SEQPESSOA = A.NROEMPRESA) !=
       (SELECT DISTINCT SUBSTR(LPAD(NROCGCCPF,12,0),1,8) FROM CONSINCO.GE_PESSOA WHERE SEQPESSOA = A.SEQPESSOA)
   AND A.SITUACAOPED NOT IN ('C','F')

UNION ALL

/* Bloqueia Forma Pagto Raz?o Diferente para emiss?es entre CNPJs raizes iguais */

SELECT DISTINCT A.NROPEDVENDA, A.NROEMPRESA, 'VERIFICAR FORMA PAGTO' CODCRITICA
   FROM CONSINCO.MAD_PEDVENDA A LEFT JOIN CONSINCO.MRL_FORMAPAGTO DD ON A.NROFORMAPAGTO = DD.NROFORMAPAGTO
   WHERE DD.NROFORMAPAGTO = 90
   AND (SELECT DISTINCT SUBSTR(LPAD(NROCGCCPF,12,0),1,8) FROM CONSINCO.GE_PESSOA WHERE SEQPESSOA = A.NROEMPRESA) =
       (SELECT DISTINCT SUBSTR(LPAD(NROCGCCPF,12,0),1,8) FROM CONSINCO.GE_PESSOA WHERE SEQPESSOA = A.SEQPESSOA)
   AND A.SITUACAOPED NOT IN ('C','F')

UNION ALL -- Giuliano - Solicitac?o Danielle Ticket 115959 - 10/10/2022

/* Bloqueia produtos com tributac?o 'IMPORTADA' e origem 'NACIONAL' */

SELECT DISTINCT G.NROPEDVENDA, G.NROEMPRESA, 'ORIG.DIVER.TRIB.VERIF.CAD COM.' CODCRITICA
FROM mad_pedvendaitem G LEFT JOIN MAD_PEDVENDA H ON G.NROPEDVENDA = H.NROPEDVENDA
WHERE G.SEQPRODUTO IN (SELECT DISTINCT A.SEQPRODUTO FROM MAP_PRODUTO A WHERE A.SEQPRODUTO = G.SEQPRODUTO AND A.SEQFAMILIA IN
                      (SELECT DISTINCT B.SEQFAMILIA FROM MAP_FAMDIVISAO B
                      LEFT JOIN CONSINCO.MAP_TRIBUTACAO C ON B.NROTRIBUTACAO = C.NROTRIBUTACAO

WHERE (UPPER(TRIBUTACAO) LIKE '%IMP%' OR UPPER(TRIBUTACAO) LIKE 'IM%')      AND CODORIGEMTRIB IN (0,4,5,7) AND UPPER(TRIBUTACAO) NOT LIKE '%LIMP%'
   OR UPPER(TRIBUTACAO) LIKE '%IMP.LIMP%'                                   AND CODORIGEMTRIB IN (0,4,5,7)))
 AND G.DTAINCLUSAO > SYSDATE - 100
 AND H.SITUACAOPED NOT IN ('C','F')

UNION ALL -- Ticket 178084 - Giuliano - 09/02/2023 - Solicitac?o Danielle
          -- Bloqueia forma de pagamento diferente de 90|99 e CGO diferente de 806, 807, 918 e 919 nas emiss?es para empresas do grupo

   SELECT DISTINCT A.NROPEDVENDA, A.NROEMPRESA, 'Forma de Pagamento Incorreta' CODCRITICA
   FROM CONSINCO.MAD_PEDVENDA A LEFT JOIN MRL_FORMAPAGTO D ON A.NROFORMAPAGTO = D.NROFORMAPAGTO
   WHERE A.NROFORMAPAGTO NOT IN (90,99)
   AND SEQPESSOA < 999
   AND A.SITUACAOPED != 'C'
   AND DTAINCLUSAO > SYSDATE - 50
   AND CODGERALOPER NOT IN (806,807,918,919,10)

UNION ALL -- Giuliano - Solic. Danielle Ticket 229724 | 15/05/2023
          -- Bloqueia emiss?o de Insumo/Uso Ativo pelas empresas 501,506 pelo CGO 93

SELECT DISTINCT A.NROPEDVENDA, A.NROEMPRESA, 'Emissao Cons/Uso At. N?o Perm' CODCRITICA
  FROM CONSINCO.MAD_PEDVENDAITEM A INNER JOIN CONSINCO.MAP_PRODUTO B ON A.SEQPRODUTO = B.SEQPRODUTO
                                   INNER JOIN CONSINCO.MAP_FAMDIVISAO X ON X.SEQFAMILIA = B.SEQFAMILIA
                                   INNER JOIN CONSINCO.MAD_PEDVENDA C ON C.NROEMPRESA = A.NROEMPRESA AND C.NROPEDVENDA = A.NROPEDVENDA

WHERE ( B.DESCCOMPLETA LIKE '%CONSUMO%' OR B.DESCCOMPLETA LIKE '%USO ATIVO%')
  AND X.FINALIDADEFAMILIA IN ('A','O', 'U')
  AND A.NROEMPRESA IN (501,506)
  AND A.DTAINCLUSAO > SYSDATE - 100
  AND C.CODGERALOPER = 93

UNION ALL -- Giuliano - Solic. Simone Ticket 245643 | 14/06/2023
          -- Bloqueia emiss?o para UF != SP pelo CGO 48

SELECT DISTINCT A.NROPEDVENDA, A.NROEMPRESA, 'CGO n?o perm. emiss?o FORA SP' CODCRITICA
   FROM CONSINCO.MAD_PEDVENDA A LEFT JOIN MRL_FORMAPAGTO D ON A.NROFORMAPAGTO = D.NROFORMAPAGTO
                                LEFT JOIN GE_PESSOA B      ON A.SEQPESSOA = B.SEQPESSOA
   WHERE 1=1
   AND B.UF != 'SP'
   AND A.SITUACAOPED != 'C'
   AND A.DTAINCLUSAO > SYSDATE - 50
   AND CODGERALOPER IN (48)

UNION ALL -- Giuliano - Tratativa Emp 502,503 no momento apenas pode utilizar tab. venda 77 para CGO 64/96

SELECT DISTINCT A.NROPEDVENDA, A.NROEMPRESA, 'Tabela de Venda Incorreta' CODCRITICA
   FROM CONSINCO.MAD_PEDVENDA A

   WHERE 1=1
   AND A.NROEMPRESA   IN (502,503)
   AND A.NROTABVENDA != 77
   AND A.CODGERALOPER = 64
   AND A.SITUACAOPED != 'C'

UNION ALL

-- Giuliano - 02/07/2024
-- Barra Prod Sem Custo Informado (Base) na tabela de custos (503)
-- Barra Prod sem a 503 como fornec principal
-- So funciona o custo correto quando fornecedor de importac?o estiver como principal e existir custo base

SELECT DISTINCT A.NROPEDVENDA, A.NROEMPRESA, 'G:Produto Sem Custo inf Tab.C' CODCRITICA
   FROM CONSINCO.MAD_PEDVENDA A INNER JOIN MAD_PEDVENDAITEM B ON A.NROPEDVENDA = B.NROPEDVENDA
                                                             AND A.NROEMPRESA  = B.NROEMPRESA
                                INNER JOIN MAP_PRODUTO P      ON P.SEQPRODUTO  = B.SEQPRODUTO

   WHERE 1=1
   AND A.NROEMPRESA   IN (502,503)
   AND A.NROTABVENDA  = 77
   AND A.CODGERALOPER = 64
   AND A.SITUACAOPED != 'C'
   AND NVL(consinco.FMSU_CUSTOCOMPRAATUAL(P.SEQFAMILIA,1,A.NROEMPRESA,'S','SP','TF',A.NROEMPRESA),0) = 0

UNION ALL

-- Giuliano em 16/10/2024 - Ticket 464094
-- Barra Prod sem tipo Industria na Familia quando o fornec é EX e emissora é CD Importador 502/503

SELECT DISTINCT A.NROPEDVENDA, A.NROEMPRESA, 'G:Tipo Fornec Incorreto - Fam' CODCRITICA

   FROM MAD_PEDVENDA A INNER JOIN MAD_PEDVENDAITEM B ON A.NROPEDVENDA = B.NROPEDVENDA
                       INNER JOIN MAP_PRODUTO P ON P.SEQPRODUTO = B.SEQPRODUTO

   WHERE 1=1
     AND EXISTS (SELECT 1 FROM MAP_FAMFORNEC FC INNER JOIN MAP_FAMILIA F ON F.SEQFAMILIA = FC.SEQFAMILIA
                                                INNER JOIN MAP_FAMDIVISAO FD ON FD.SEQFAMILIA = F.SEQFAMILIA
                  WHERE FC.SEQFORNECEDOR IN (502,503)
                    AND NVL(FC.TIPFORNECEDORFAM, 'X') != 'I'
                    AND EXISTS (SELECT 1 FROM MAP_FAMFORNEC EX INNER JOIN GE_PESSOA G ON G.SEQPESSOA = EX.SEQFORNECEDOR
                                 WHERE EX.SEQFAMILIA = FC.SEQFAMILIA
                                   AND UF = 'EX')
                                   AND NVL(FD.FINALIDADEFAMILIA,'X') != 'U'
                                   AND F.SEQFAMILIA = P.SEQFAMILIA)

   AND A.NROEMPRESA IN (502,503)
   AND A.DTAINCLUSAO > SYSDATE - 20
;

