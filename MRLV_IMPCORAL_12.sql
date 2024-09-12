-- Original

create or replace view consinco.mrlv_impcoral_12 as
select substr(a.linha, 0,   1)                             tipo,
         to_number(substr(a.linha, 2,   6))                  ncupom,
         to_number(substr(a.linha, 8,   3))                  ncaixa,
         to_number(substr(a.linha, 11,  4))                  nloja,
         substr(a.linha, 15,  8)                             resposta,
         to_number(substr(a.linha, 23,  6))                  item,
         to_number(trim(substr(a.linha, 29,  20)))           codlido,
         to_char(substr(a.linha, 49,  14))                   codconsarq,
         to_number(substr(a.linha, 63,  9))/1000             qtd,
         to_number(substr(a.linha, 72,  12)/100)             precounit,
         trim(substr(a.linha, 84,  3))                       tributo,
         substr(a.linha, 87,  40)                            descricao,
         substr(a.linha, 127, 12)                            desconto,
         substr(a.linha, 139, 1)                             tipodesconto,
         to_number(trim(substr(a.linha, 140, 12)))/100       totalitem,
         to_number(trim(substr(a.linha, 152, 12)))/100       totaldesc,
         substr(a.linha, 164, 1)                             origem,
         substr(a.linha, 165, 32)                            nomecampo,
         substr(a.linha, 197, 1)                             pesavel,
         substr(a.linha, 198, 210)                           campoextra,
         substr(a.linha, 408, 2)                             unidade,
         nvl(substr(a.linha, 410, 5),0)                      aliquota,
         to_number(trim(substr(a.linha, 415, 10)))/100       impostototal,
         to_number(trim(substr(a.linha, 425, 10)))/100       impostofederal,
         to_number(trim(substr(a.linha, 435, 10)))/100       impostoestadual,
         to_number(trim(substr(a.linha, 445, 10)))/100       impostomunicipal,
         substr(a.linha, 200, 13)                            codbarrascesta,
         to_number(trim(substr(a.linha, 216, 3)))            qtdecesta,
         to_number(trim(substr(a.linha, 222, 3)))            nrocesta,
         to_number(trim(substr(a.linha, 231, 6)))            seqprodcesta,
         substr(a.linha, length(linha)-11, 12)               seqregistrofrente,
         to_date(substr(a.linha, 484,8),'dd-mm-rrrr')        dtamovimento,
         a.seqnotafiscal                                     seqdocto,
         arquivo
  from   mrlx_pdvimportacao a
  where  (substr(a.linha, 0, 1) = '1'  or      -- venda
          substr(a.linha, 0, 1) = '2')
;

-- Alterada

create or replace view mrlv_impcoral_12 as
select   /*Altera */

         substr(a.linha, 0,   1)                             tipo,
         to_number(substr(a.linha, 2,   6))                  ncupom,
         to_number(substr(a.linha, 8,   3))                  ncaixa,
         to_number(substr(a.linha, 11,  4))                  nloja,
         substr(a.linha, 15,  8)                             resposta,
         to_number(substr(a.linha, 23,  6))                  item,
         to_number(trim(substr(a.linha, 29,  20)))           codlido,
         to_char(substr(a.linha, 49,  14))                   codconsarq,
         to_number(substr(a.linha, 63,  9))/1000             qtd,
         to_number(substr(a.linha, 72,  12)/100)             precounit,
         trim(substr(a.linha, 84,  3))                       tributo,
         substr(a.linha, 87,  40)                            descricao,
         substr(a.linha, 127, 12)                            desconto,
         substr(a.linha, 139, 1)                             tipodesconto,
         to_number(trim(substr(a.linha, 140, 12)))/100       totalitem,
         to_number(trim(substr(a.linha, 152, 12)))/100       totaldesc,
         substr(a.linha, 164, 1)                             origem,
         substr(a.linha, 165, 32)                            nomecampo,
         substr(a.linha, 197, 1)                             pesavel,
         substr(a.linha, 198, 210)                           campoextra,
         substr(a.linha, 408, 2)                             unidade,
         nvl(substr(a.linha, 410, 5),0)                      aliquota,
         to_number(trim(substr(a.linha, 415, 10)))/100       impostototal,
         to_number(trim(substr(a.linha, 425, 10)))/100       impostofederal,
         to_number(trim(substr(a.linha, 435, 10)))/100       impostoestadual,
         to_number(trim(substr(a.linha, 445, 10)))/100       impostomunicipal,
         --substr(a.linha, 200, 13)                            codbarrascesta,
         LPAD(REGEXP_REPLACE(substr(a.linha, 200, 13), '[^0-9]', ''),13,0) codbarrascesta,
         --to_number(trim(substr(a.linha, 216, 3)))            qtdecesta,
         TO_NUMBER(LPAD(REGEXP_REPLACE(trim(substr(a.linha, 216, 3)), '[^0-9]', ''),3,0)) qtdecesta,
         --to_number(trim(substr(a.linha, 222, 3)))            nrocesta,
         TO_NUMBER(LPAD(REGEXP_REPLACE(trim(substr(a.linha, 222, 3)),'[^0-9]', ''),3,0)) nrocesta,
         to_number(trim(REGEXP_REPLACE(substr(a.linha, 230, 7),'[^0-9]', '')))        seqprodcesta,
         substr(a.linha, length(linha)-11, 12)               seqregistrofrente,
         to_date(substr(a.linha, 484,8),'dd-mm-rrrr')        dtamovimento,
         a.seqnotafiscal                                     seqdocto,
         arquivo
  from   mrlx_pdvimportacao a
  where  (substr(a.linha, 0, 1) = '1'  or      -- venda
          substr(a.linha, 0, 1) = '2')
;
