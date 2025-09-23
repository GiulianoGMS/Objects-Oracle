CREATE OR REPLACE PROCEDURE NAGP_ENVIO_ACORDO_PENDENTE_EMAIL (psCodComprador VARCHAR2, psEnviaTICopia VARCHAR2) AS
    vsQtd    NUMBER(30);
    vsEmail  VARCHAR2(200);
    vsNome   VARCHAR2(200);
    vsTable  CLOB := EMPTY_CLOB();
    vsHtml   CLOB := EMPTY_CLOB();
    psEmailTI VARCHAR2(1000);
    psNroAcordo   NUMBER(30);
BEGIN
    -- Envia para TI em copia
    IF psEnviaTICopia = 'S' 
      THEN
        psEmailTI := 'giuliano.gomes@nagumo.com.br;marcel.cipolla@nagumo.com.br;';
    END IF;
    
    -- Quantidade de acordos
    SELECT COUNT(1)
      INTO vsQtd
      FROM NAGV_TAE_ACORDOS A
     WHERE A.COD_COMPRADOR = psCodComprador
       AND A.VENCIMENTO >= TRUNC(SYSDATE)
       AND STATUS IN ('Aguardando assinatura do envelope','Pendente','Envelope rejeitado', 'Envelope Cancelado', 'Fornecedor sem e-mail cadastrado.') ;

    IF vsQtd = 0 THEN
       RETURN; -- não há acordos
    END IF;

    -- Pega dados do comprador
    SELECT MAX(B.EMAIL), MAX(B.NOME)
      INTO vsEmail, vsNome
      FROM NAGV_TAE_ACORDOS A
            LEFT JOIN NAGT_EMAILCOMPRADORES B ON A.COD_COMPRADOR = B.SEQCOMPRADOR
     WHERE A.COD_COMPRADOR = psCodComprador
       AND STATUS IN ('Aguardando assinatura do envelope','Pendente','Envelope rejeitado', 'Envelope Cancelado', 'Fornecedor sem e-mail cadastrado.');

    -- Monta as linhas da tabela
    
    FOR t IN (
        SELECT A.NRO_ACORDO,
               TO_CHAR(A.VLR_ACORDO,'FM999G999G990D90', 'NLS_NUMERIC_CHARACTERS='',.''') VLR_ACORDO,
               TO_CHAR(A.VENCIMENTO, 'DD/MM/YYYY') VENCIMENTO,
               INITCAP(A.TIPO_ACORDO) TIPO_ACORDO, STATUS
          FROM NAGV_TAE_ACORDOS A
         WHERE A.COD_COMPRADOR = psCodComprador
           AND A.VENCIMENTO >= TRUNC(SYSDATE)
           AND STATUS IN ('Aguardando assinatura do envelope','Pendente','Envelope rejeitado', 'Envelope Cancelado', 'Fornecedor sem e-mail cadastrado.')
           AND NOT EXISTS (SELECT 1 FROM NAGT_LOG_ENVIO_ACO_EMAIL L WHERE L.NRO_ACORDO = A.NRO_ACORDO AND TRUNC(L.DATA_ENVIO) = TRUNC(SYSDATE))
    )
    LOOP
      psNroAcordo := t.Nro_Acordo;
        vsTable := vsTable ||
                   '<tr>' ||
                   '<td style="padding:8px 12px;font-size:13px;border-bottom:1px solid #e6e9ef;">' || t.NRO_ACORDO || '</td>' ||
                   -- Preciei mudar o style pois a ultima linha estava ficando desproporcional
                   '<td style="max-width:250px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;padding:8px 12px;font-size:13px;border-bottom:1px solid #e6e9ef;">' || t.TIPO_ACORDO || '</td>' ||
                   '<td style="padding:8px 12px;font-size:13px;border-bottom:1px solid #e6e9ef;">' || t.VENCIMENTO || '</td>' ||
                   '<td style="padding:8px 12px;text-align:right;
            font-size:13px;border-bottom:1px solid #e6e9ef;
            width:120px;white-space:nowrap;"> R$ ' || t.VLR_ACORDO || '</td>' ||
                   '<td style="padding:8px 12px;text-align:right;font-size:13px;border-bottom:1px solid #e6e9ef;"> ' || t.STATUS || '</td>' ||
                   '</tr>';
    END LOOP;

    -- Monta o corpo completo do e-mail
    vsHtml := '<!doctype html>
    <html lang="pt-BR">
    <head>
      <meta charset="utf-8">
      <meta name="viewport" content="width=device-width,initial-scale=1">
    </head>
    <body style="margin:0;padding:0;background:#f3f4f6;font-family:Arial,Helvetica,sans-serif;color:#111;">
      <table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="background:#f3f4f6;padding:24px 0;">
        <tr>
          <td align="center">
            <table role="presentation" width="900" style="max-width:900px;background:#ffffff;border-radius:8px;overflow:hidden;box-shadow:0 6px 18px rgba(17,24,39,0.08);">
              <!-- Header -->
              <tr>
                <td style="padding:24px 28px;background:linear-gradient(90deg,#0b6efd,#1e90ff);color:#fff;">
                  <table role="presentation" width="100%">
                    <tr>
                      <td style="vertical-align:middle;">
                        <img src="https://blog.nagumo.com.br/wp-content/uploads/2023/04/Horizontal_positivo800px.png" alt="Nagumo Delivery" width="120">
                      </td>
                      <td align="right" style="vertical-align:middle;color:#0b2545;font-size:14px;">
                        <strong style="font-size:15px;">Comercial | Supermercados Nagumo</strong><br>
                        Acordos pendentes
                      </td>
                    </tr>
                  </table>
                </td>
              </tr>

              <!-- Greeting -->
              <tr>
                <td style="padding:20px 28px 0 28px;">
                  <h2 style="margin:0 0 8px 0;font-size:20px;color:#0b2545;">Olá, ' || vsNome || ' :)</h2>
                  <p style="margin:0;color:#374151;font-size:14px;line-height:1.5;">
                    Você tem <strong style="color:#0b6efd">' || vsQtd || '</strong> acordo(s) comercial(is) pendente(s) no TAE (Totvs Assinatura Eletrônica)
                  </p>
                </td>
              </tr>

              <!-- Agreements table -->
              <tr>
                <td style="padding:18px 20px;">
                  <table role="presentation" width="100%" cellpadding="8" cellspacing="0" style="border-collapse:collapse;">
                    <thead>
                      <tr>
                        <th style="text-align:left;font-size:12px;color:#6b7280;padding:10px 12px;border-bottom:1px solid #e6e9ef;">Acordo</th>
                        <th style="text-align:left;font-size:12px;color:#6b7280;padding:10px 12px;border-bottom:1px solid #e6e9ef;">Tipo</th>
                        <th style="text-align:left;font-size:12px;color:#6b7280;padding:10px 12px;border-bottom:1px solid #e6e9ef;">Vencimento</th>
                        <th style="text-align:center;font-size:12px;color:#6b7280;padding:10px 12px;border-bottom:1px solid #e6e9ef;">Valor</th>
                        <th style="text-align:center;font-size:12px;color:#6b7280;padding:10px 12px;border-bottom:1px solid #e6e9ef;">Status</th>
                      </tr>
                    </thead>
                    <tbody>' || vsTable || '</tbody>
                  </table>
                </td>
              </tr>

              <!-- CTA -->
              <tr>
                <td style="padding:12px 28px 24px 28px;">
                  <table role="presentation" width="100%">
                    <tr>
                      <td>
                        <a href="https://nagumo.autosky.cloud" style="display:inline-block;padding:12px 20px;border-radius:8px;background:#0b6efd;color:#fff;text-decoration:none;font-weight:600;">Acessar Totvs-Consinco</a>
                      </td>
                      <td align="right" style="vertical-align:middle;">
                        <p style="margin:0;font-size:12px;color:#9ca3af;">Acesse o ERP para enviar os acordos que estiverem pendentes</p>
                      </td>
                    </tr>
                  </table>
                </td>
              </tr>

              <!-- Footer info -->
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

            <!-- Small print -->
            <table role="presentation" width="900" style="max-width:900px;margin-top:12px;">
              <tr>
                <td style="font-size:12px;color:#9ca3af;text-align:center;padding:8px 16px;">
                  Você está recebendo este e-mail porque é responsável por enviar este acordo. Se não for o responsável, ignore esta mensagem.
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

    -- Envia apenas 1 e-mail consolidado
    CONSINCO.SP_ENVIA_EMAIL(
        CONSINCO.C5_TP_PARAM_SMTP(1),
        psEmailTI||vsEmail,
        'Acordos Pendentes no TAE - Totvs Assinatura Eletrônica',
        vsHtml,
        'N');
        
     -- Grava log

    INSERT INTO NAGT_LOG_ENVIO_ACO_EMAIL (
        COD_COMPRADOR,
        EMAIL_DESTINO,
        QTDE_ACORDOS,
        HTML_EMAIL,
        DATA_ENVIO,
        NRO_ACORDO
    ) VALUES (
        psCodComprador,
        psEmailTI||vsEmail,
        vsQtd,
        vsHtml,
        SYSDATE,
        psNroAcordo
    );
    COMMIT;  

END;
