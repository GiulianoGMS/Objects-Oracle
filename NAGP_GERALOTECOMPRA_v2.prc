CREATE OR REPLACE PROCEDURE NAGP_GERALOTECOMPRA_v2 AS
    i INTEGER := 0;
    v_NroLote NUMBER;
    v_DtaInclusao DATE;
    vsHtml CLOB := EMPTY_CLOB();
BEGIN
    -- Desabilita agenda dos lotes do dia que estão configurados
    FOR g IN (
        SELECT D.SEQLOTEMODELO
        FROM CONSINCO.NAGV_BUSCADTAPEDIDO D
        WHERE EXISTS (
            SELECT 1
            FROM CONSINCO.MAC_GERCOMPRA Z
            WHERE Z.SEQGERCOMPRA = D.SEQLOTEMODELO
              AND (Z.AGENDADOMINGO = 'S' OR
                   Z.AGENDASEGUNDA = 'S' OR
                   Z.AGENDATERCA   = 'S' OR
                   Z.AGENDAQUARTA  = 'S' OR
                   Z.AGENDAQUINTA  = 'S' OR
                   Z.AGENDASEXTA   = 'S' OR
                   Z.AGENDASABADO  = 'S')
        )
    ) LOOP
        BEGIN
            UPDATE CONSINCO.MAC_GERCOMPRA X
            SET X.AGENDADOMINGO = 'N',
                X.AGENDASEGUNDA = 'N',
                X.AGENDATERCA   = 'N',
                X.AGENDAQUARTA  = 'N',
                X.AGENDAQUINTA  = 'N',
                X.AGENDASEXTA   = 'N',
                X.AGENDASABADO  = 'N'
            WHERE X.SEQGERCOMPRA = g.SEQLOTEMODELO
              AND X.TIPOLOTE = 'M';
            COMMIT;
        END;
    END LOOP;

    -- Processa lotes que devem ser gerados no momento
    FOR t IN (
        SELECT SEQLOTEMODELO, C.COMPRADOR, G.DESCRITIVO, P.NOMERAZAO FORNECEDOR,
               D.DATA_VALIDA, D.HORAMIN,
               NVL(A.EMAIL || CASE WHEN E.EMAIL IS NULL OR A.EMAIL IS NULL THEN NULL ELSE ';' END || E.EMAIL, 'X') EMAIL,
               INITCAP(NVL(NVL(A.COMPRADOR,U.NOME), C.COMPRADOR)) NOME,
               FORMACALC
        FROM CONSINCO.NAGV_BUSCADTAPEDIDO D   LEFT JOIN CONSINCO.MAC_GERCOMPRA G ON G.SEQGERCOMPRA = D.SEQLOTEMODELO AND G.TIPOLOTE = 'M'
                                             INNER JOIN CONSINCO.GE_PESSOA P ON P.SEQPESSOA = G.SEQFORNECPRINCIPAL
                                             INNER JOIN CONSINCO.MAX_COMPRADOR C ON C.SEQCOMPRADOR = G.SEQCOMPRADOR
                                              LEFT JOIN CONSINCO.NAGT_EMAILCOMPRADORES A ON UPPER(A.COMPRADOR) = C.APELIDO
                                              LEFT JOIN CONSINCO.NAGT_EMAILCOMPRADORES E ON UPPER(E.COMPRADOR) = D.ASSISTENTE
                                              LEFT JOIN CONSINCO.GE_USUARIO U ON U.CODUSUARIO = D.ASSISTENTE
                                              
        WHERE SYSDATE >= TO_DATE(TO_CHAR(D.DATA_VALIDA,'DD/MM/YYYY')||' '||D.HORAMIN,'DD/MM/YYYY HH24:MI')
          AND NOT EXISTS (
              SELECT 1
              FROM CONSINCO.MAC_GERCOMPRA Y
              WHERE Y.SEQGERMODELOCOMPRA = D.SEQLOTEMODELO
                AND TRUNC(DTAHORINCLUSAO) = TRUNC(SYSDATE)
                AND SITUACAOLOTE != 'C'
          )
          AND G.SITUACAOLOTE != 'C'
        ORDER BY HORAMIN ASC
    ) LOOP
        BEGIN
            -- Cria o lote
            i := i + 1;
            CONSINCO.NAGP_spMac_GeraLoteCompra(TRUNC(SYSDATE), 'N', t.SEQLOTEMODELO);

            -- Insere log de geração
            INSERT INTO CONSINCO.NAGT_LOGGERALOTEAUTO VALUES (t.SEQLOTEMODELO, SYSDATE, 'JOBGERALOTE', 'GERADO', 'COMPRAS');

            -- Recupera número do lote gerado
            IF i = 1 THEN
                COMMIT;
                i := 0;
                SELECT MAX(SEQGERCOMPRA), MAX(MC.DTAHORINCLUSAO)
                  INTO v_NroLote, v_DtaInclusao
                  FROM CONSINCO.MAC_GERCOMPRA MC
                 WHERE MC.SEQGERMODELOCOMPRA = t.SEQLOTEMODELO
                   AND MC.SITUACAOLOTE != 'C';
            END IF;

            -- Atualiza sugestão de compra se parametrizado
            IF t.FORMACALC IS NOT NULL AND v_DtaInclusao >= TRUNC(SYSDATE) THEN
                NAGPKG_SUGESTAO_COMPRA.NAGP_ATUALIZA_SUGESTAO(v_NroLote, t.FORMACALC);
            END IF;

            -- Monta e envia e-mail estilizado
            IF 1=1 --v_DtaInclusao >= TRUNC(SYSDATE) THEN
                THEN vsHtml := '<!doctype html>
        <html lang="pt-BR">
        <head>
          <meta charset="utf-8">
          <meta name="viewport" content="width=device-width,initial-scale=1">
        </head>
        <body style="margin:0;padding:0;background:#f3f4f6;font-family:Arial,Helvetica,sans-serif;color:#111;">
          <table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="background:#f3f4f6;padding:24px 0;">
            <tr>
              <td align="center">
                <table role="presentation" width="700" style="max-width:700px;background:#ffffff;border-radius:8px;overflow:hidden;box-shadow:0 6px 18px rgba(17,24,39,0.08);">
                  <tr>
                    <td style="padding:24px 28px;background:linear-gradient(90deg,#0b6efd,#1e90ff);color:#fff;">
                      <table role="presentation" width="100%">
                        <tr>
                          <td style="vertical-align:middle;">
                            <img src="https://blog.nagumo.com.br/wp-content/uploads/2023/04/Horizontal_positivo800px.png" alt="Nagumo Delivery" width="120">
                          </td>
                          <td align="right" style="vertical-align:middle;color:#0b2545;font-size:14px;">
                            <strong style="font-size:15px;">Comercial | Supermercados Nagumo</strong><br>
                            Lote de Compras Gerado com Sucesso
                          </td>
                        </tr>
                      </table>
                    </td>
                  </tr>
                  <tr>
                    <td style="padding:20px 28px 0 28px;">
                      <h2 style="margin:0 0 8px 0;font-size:20px;color:#0b2545;">Olá, ' || t.NOME || ' :)</h2>
                      <p style="margin:0;color:#374151;font-size:14px;line-height:1.5;">
                        O lote <strong style="color:#0b6efd">' || v_NroLote || '</strong> para o fornecedor <strong>' || t.FORNECEDOR || '</strong> foi gerado com sucesso!
                      </p>
                      <p style="margin:8px 0 0 0;color:#374151;font-size:14px;">Descrição do Lote: ' || t.DESCRITIVO || '</p>
                      <p style="margin:8px 0 0 0;color:#374151;font-size:14px;">Número do Lote: ' || t.DESCRITIVO || '</p>
                    </td>
                  </tr>
                  <tr>
                    <td style="padding:18px 28px;">
                      <a href="url" style="display:inline-block;padding:12px 20px;border-radius:8px;background:#0b6efd;color:#fff;text-decoration:none;font-weight:600;">Acessar Totvs-Consinco</a>
                    </td>
                  </tr>
                  <tr>
                    <td style="padding:18px 28px;background:#f9fafb;border-top:1px solid #eef2f7;">
                      <table role="presentation" width="100%">
                        <tr>
                          <td style="font-size:13px;color:#6b7280;line-height:1.4;">
                            <strong>SUPERMERCADOS NAGUMO</strong><br>
                            Precisa de ajuda?<br>
                            Contate sistemas.ti@nagumo.com.br.
                          </td>
                          <td align="right" style="font-size:12px;color:#9ca3af;">
                            Enviado automaticamente, não responda!<br>
                            <span style="display:block;margin-top:6px;">© ' || TO_CHAR(SYSDATE, 'DD/MM/YYYY HH24:MI') || '</span>
                          </td>
                        </tr>
                      </table>
                    </td>
                  </tr>
                </table>
                <table role="presentation" width="700" style="max-width:700px;margin-top:12px;">
                  <tr>
                    <td style="font-size:12px;color:#9ca3af;text-align:center;padding:8px 16px;">
                      Você está recebendo este e-mail porque é responsável pelo lote. Se não for o responsável, ignore esta mensagem.
                    </td>
                    <td style="font-size:12px;color:#9ca3af;text-align:center;padding:8px 16px;">
                      Desenvolvido por Giuliano Gomes & Marcel Cipolla.
                    </td>
                  </tr>
                </table>
              </td>
            </tr>
          </table>
        </body>
        </html>';

                CONSINCO.SP_ENVIA_EMAIL(
                    CONSINCO.C5_TP_PARAM_SMTP(1),
                    'email'
                            ||T.EMAIL||';',  
                    'Lote de Compras Gerado com Sucesso! Fornecedor: ' || t.FORNECEDOR,
                    vsHtml,
                    'N'
                );
            END IF;

        EXCEPTION
            WHEN OTHERS THEN
                -- Insere logs em caso de erro
                INSERT INTO CONSINCO.NAGT_LOGGERALOTEAUTO VALUES (t.SEQLOTEMODELO, SYSDATE, 'JOBGERALOTE', 'ERRO', 'COMPRAS');
                COMMIT;

                -- Envia e-mail de erro
                CONSINCO.SP_ENVIA_EMAIL(
                    CONSINCO.C5_TP_PARAM_SMTP(1),
                    'email',
                    'Erro na geração de lote de compras - Lote Modelo: ' || t.SEQLOTEMODELO,
                    'Lote Modelo: ' || t.SEQLOTEMODELO || CHR(10) ||
                    'Data: ' || TO_CHAR(SYSDATE,'DD/MM/YYYY HH24:Mi:ss') || CHR(10) ||
                    '* Erro na geração de lote de compras pelo Job * - Erro: ' || SQLERRM,
                    'N'
                );
                COMMIT;
        END;
    END LOOP;

    COMMIT;
END NAGP_GERALOTECOMPRA_v2;
