create or replace procedure sp_carga_preco_nagumo_v2(pnNroJob     in   number,
                                                     pnModEmpresa in   number   ) is
  vsSoft           varchar2(50);
  vsHora           varchar2(2);
  vsTipoCarga      varchar2(10);
  obj_param_smtp   c5_tp_param_smtp;
  vsSql            varchar2(2000);
begin
  select to_char(sysdate, 'HH24')
  into   vsHora
  from   dual;
  if vsHora in ('01', '09', '13')  then
     vsSql :=
     'insert into nag_job(nrojob, dtamovimento,    erro)
                 values ('||pnNroJob||',    trunc(sysdate), ''Inicio: ' || to_char(sysdate,'dd-mm-yyyy HH24:mi:ss')||''')';
     execute immediate vsSql;
  end if;
  if vsHora = '01' then
     vsTipoCarga := 'Total';
  elsif vsHora in ('09', '13')  then
        vsTipoCarga := 'Parcial';
  end if;
  if vsHora in ('01', '09', '13')  then
     for i in (select * from max_empresa a
               where a.status = 'A'
               and  mod(a.nroempresa,5) = pnModEmpresa
               and  nroempresa < 500
               order by 1)
     loop
       obj_param_smtp := c5_tp_param_smtp(1);
       if vsHora in ('01', '09', '13')  then
          if vsHora <> '03' then
             --gerando promocao
             pkg_mad_admpreco.SP_GeraPromocao(i.nrosegmentoprinc, i.nroempresa, trunc(sysdate), 'AUTOMATICO');
             --validando precos
             pkg_mad_admpreco.SP_ValidaPreco(i.nrosegmentoprinc, i.nroempresa,'AUTOMATICO', 'T');
          end if;
          begin
            spmrl_cargapdvcoral(i.nroempresa, trunc(sysdate), vsTipoCarga, null);
            commit;
          exception
            when others then

              --- Comentado por Cipolla em 06/03/2023, caso apresente erro será enviado e-mail. Solicitação Lucimar - Ticket c5 16317714
/*              vsSql :=
              'insert into nag_job(nrojob, dtamovimento,  nroempresa,  erro)
                          values ('||pnNroJob||',    trunc(sysdate), i.nroempresa, ''Erro ao gerar a carga de PDV da empresa'')';
              execute immediate vsSql;*/

              sp_envia_email(obj_param      => obj_param_smtp,
                             psDestinatario => 'giuliano.gomes@nagumo.com.br',
                             psAssunto      => 'Erro ao gerar a carga de PDV da empresa ' || to_char(i.nroempresa),
                             psMensagem     => 'Erro ao gerar a carga de PDV da empresa ' || to_char(i.nroempresa),
                             psindusahtml   => 'N');
          end;
          -- Adicionado por Giuliano - Tratamento Parcial/Total Balanca
          IF vsTipoCarga = 'Total' THEN
          begin
            for bal in (select nroempresa, softpdv
                        from   mrl_empsoftpdv
                        where  tiposoft   =  'B'
                        and    nroempresa =  i.nroempresa)
            loop
              insert  into mrl_logexportacao(nroempresa,       softpdv,         dtahorexportacao,     usuexportacao,
                                             tipolog,          param1,          param2,               param3,
                                             param4,           param5,          dtamovimento )
                                   values   (bal.nroempresa,   bal.softpdv,     sysdate,              'JOB209',
                                             'T',              null,            null,                 trunc(sysdate),
                                             null,             null,            null) ;
              commit;
            end loop;
            exception

            when others then

              sp_envia_email(obj_param      => obj_param_smtp,
                             psDestinatario => 'giuliano.gomes@nagumo.com.br',
                             psAssunto      => 'Erro ao gerar a carga TOTAL da balança da empresa: ' || to_char(i.nroempresa),
                             psMensagem     => 'Erro ao gerar a carga TOTAL da balança da empresa: ' || to_char(i.nroempresa),
                             psindusahtml   => 'N');
            END;
          ELSE -- Parcial
            BEGIN
              ESPP_CPT_GERACARGATOLETO(i.NROEMPRESA,SYSDATE, 'N');
               COMMIT;                
                
              exception

            when others then

              sp_envia_email(obj_param      => obj_param_smtp,
                             psDestinatario => 'giuliano.gomes@nagumo.com.br',
                             psAssunto      => 'Erro ao gerar a carga PARCIAL da balança da empresa: ' || to_char(i.NROEMPRESA),
                             psMensagem     => 'Erro ao gerar a carga PARCIAL da balança da empresa: ' || to_char(i.nroempresa),
                             psindusahtml   => 'N');
             END;
           --
           END IF;

       end if;
     end loop;
  end if;
  if vsHora in ('01', '09', '13')  then
     vsSql :=
     'insert into nag_job(nrojob, dtamovimento,    erro)
                 values ('||pnNroJob||',    trunc(sysdate), ''Final: ' || to_char(sysdate,'dd-mm-yyyy HH24:mi:ss')||''')';
  end if;
  commit;
end sp_carga_preco_nagumo_v2;
