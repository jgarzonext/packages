--------------------------------------------------------
--  DDL for Function F_TRECIBO_MV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_TRECIBO_MV" (
   pnrecibo IN NUMBER,
   pcidioma IN NUMBER,
   ptlin1 OUT VARCHAR2,
   ptlin2 OUT VARCHAR2,
   ptlin3 OUT VARCHAR2,
   ptlin4 OUT VARCHAR2,
   ptlin5 OUT VARCHAR2,
   ptlin6 OUT VARCHAR2,
   ptlin7 OUT VARCHAR2,
   ptlin8 OUT VARCHAR2)
   RETURN NUMBER AUTHID CURRENT_USER IS
/***************************************************************************
   F_TRECIBO: Devuelve el texto de los recibos
   ALLIBADM.
   ESPECIFICO PARA MARCH VIDA
****************************************************************************/
   v_npoliza      NUMBER;
   v_validez      VARCHAR2(40);
   v_producto     VARCHAR2(40);
   v_asegurado    VARCHAR2(40);
   v_fpago        VARCHAR2(20);
   v_lit1         VARCHAR2(400);
   v_lit2         VARCHAR2(400);
   v_lit3         VARCHAR2(400);
   v_lit4         VARCHAR2(400);
   v_lit5         VARCHAR2(400);
   v_lit6         VARCHAR2(400);
   v_lit7         VARCHAR2(400);
BEGIN
   IF pnrecibo IS NOT NULL
      AND pcidioma IS NOT NULL THEN
      -- Seleccion de valores:
      BEGIN
         --Bug10612 - 07/07/2009 - DCT (canviar vista personas)
         SELECT t.ttitulo,
                DECODE(r.cforpag,
                       0, 'Única',
                       1, 'Anual',
                       2, 'Semestral',
                       4, 'Trimestral',
                       12, 'Mensual'),
                s.npoliza, NULL,
                --       Pac_Isqlfor.f_periodo_recibo(pnrecibo),
                SUBSTR(d.tnombre, 0, 20) || ' ' || SUBSTR(d.tapelli1, 0, 40) || ' '
                || SUBSTR(d.tapelli2, 0, 20)
           INTO v_producto,
                v_fpago,
                v_npoliza, v_validez,
                v_asegurado
           FROM titulopro t, seguros s, recibos r, asegurados a, per_personas p, per_detper d
          WHERE s.cramo = t.cramo
            AND s.cmodali = t.cmodali
            AND s.ctipseg = t.ctipseg
            AND s.ccolect = t.ccolect
            AND s.sseguro = r.sseguro
            AND s.sseguro = a.sseguro
            AND a.sperson = p.sperson
            AND a.norden = 1   --> Solo sale el primer asegurado
            AND t.cidioma = pcidioma
            AND r.nrecibo = pnrecibo
            AND d.sperson = p.sperson
            AND d.cagente = ff_agente_cpervisio(s.cagente, f_sysdate, s.cempres);
      /*SELECT t.ttitulo,
             DECODE(r.cforpag,
                    0, 'Única',
                    1, 'Anual',
                    2, 'Semestral',
                    4, 'Trimestral',
                    12, 'Mensual'),
             s.npoliza, NULL,
                              --       Pac_Isqlfor.f_periodo_recibo(pnrecibo),
                              p.tnombre || ' ' || tapelli1 || ' ' || tapelli2
        INTO v_producto,
             v_fpago,
             v_npoliza, v_validez, v_asegurado
        FROM titulopro t, seguros s, recibos r, asegurados a, personas p
       WHERE s.cramo = t.cramo
         AND s.cmodali = t.cmodali
         AND s.ctipseg = t.ctipseg
         AND s.ccolect = t.ccolect
         AND s.sseguro = r.sseguro
         AND s.sseguro = a.sseguro
         AND a.sperson = p.sperson
         AND a.norden = 1   --> Solo sale el primer asegurado
         AND t.cidioma = pcidioma
         AND r.nrecibo = pnrecibo;*/

      --FI Bug10612 - 07/07/2009 - DCT (canviar vista personas)
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;

      -- Composicion de la lineas
      BEGIN
         -- Literales fijos
         v_lit1 := f_axis_literales(102829, pcidioma);   --> nº poliza (102829)
         v_lit2 := f_axis_literales(100864, pcidioma);   --> nº recibo (100864)
         v_lit3 := f_axis_literales(101371, pcidioma);   --> Asegurado (101371)
         v_lit4 := f_axis_literales(102719, pcidioma);   --> Forma de pago (102719)
         v_lit5 := f_axis_literales(100681, pcidioma);   --> Producto (100681)
         --    p_literal2(112475, pcidioma, v_lit6); --> Fecha de efecto (112475)
         --    p_literal2(151338, pcidioma, v_lit7); --> Periodo de cobertura (151338)
         -- Lineas del recibo
         ptlin1 := RPAD(v_lit1 || ' ' || v_npoliza, 40, ' ')
                   || RPAD(v_lit2 || ' ' || pnrecibo, 40, ' ');
         ptlin2 := RPAD(v_lit5 || ' ' || v_producto, 40, ' ')
                   || RPAD(v_lit4 || ' ' || v_fpago, 40, ' ');
         ptlin3 := RPAD(v_lit3 || ' ' || v_asegurado, 40, ' ');
         ptlin4 := v_validez;
         RETURN 0;
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;
   END IF;
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_TRECIBO_MV" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_TRECIBO_MV" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_TRECIBO_MV" TO "PROGRAMADORESCSI";
