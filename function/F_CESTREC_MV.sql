--------------------------------------------------------
--  DDL for Function F_CESTREC_MV
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION F_CESTREC_MV (
   pnrecibo IN NUMBER,
   pidioma IN NUMBER,
   pfestrec IN DATE DEFAULT NULL)
   RETURN NUMBER IS
   /*************************************************************************
      F_cestrec_MV: Retorna los sub-estados de un recibo (March Vida)
      Distinguiremos las siguientes situaciones:
         - Pendiente
           0 -- Pendiente: en el momento de generarse el recibo
           4 -- Impagado: si ha sido devuelto
         - Cobrado
           1 -- Cobrado: si ha pasado más de 35 días después del cobro (domiciliado)
           3 -- Gestión Cobro: si no han pasado 35 días
         -  Anulado
           2 -- Anulado

      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------  ------------------------------------
       1.0       -            -         1. Creación de package
       1.1        27/03/2009   APD      1. Bug 9446 (precisiones var numericas)
       2.0        09/07/2009   ETM      2.BUG 0010676: CEM - Días de gestión de un recibo
       3.0        22/09/2009   NMM      3. 10676: CEM - Días de gestión de un recibo ( canviar paràmetre)
       4.0        18/02/2010   JMF      4. 0012679 CEM - Treure la taula MOVRECIBOI
       5.0        06/03/2015   KJSC     5. BUG 35103-200056

   *************************************************************************/

   -- ini Bug 0012679 - 18/02/2010 - JMF: Control errors
   vobject        VARCHAR2(500) := 'F_CESTREC_MV';
   vparam         VARCHAR2(500)
                          := 'parámetros - pnrecibo: ' || pnrecibo || ', pidioma: ' || pidioma;
   vpasexec       NUMBER(5) := 1;
   -- fin Bug 0012679 - 18/02/2010 - JMF: Control errors
   cestado        NUMBER;
   w_num_aux      NUMBER;
   xcestaux       NUMBER;
   v_fmovini      DATE;
   tipcobro       NUMBER;
   dias_gestion   NUMBER;
   -- 10676.22/09/2009.NMM. Substituïm el paràmetre pnrecibo per w_empresa.
   w_empresa      empresas.cempres%TYPE;
   vfestrec       DATE;
   v_empresa      NUMBER;
--
BEGIN
   vfestrec := pfestrec;

   IF pfestrec IS NULL THEN
      vfestrec := f_sysdate;
   END IF;

   vpasexec := 1;
   --
   -- Miramos si el recibo está impagado
   --
   vpasexec := 2;
   w_num_aux := f_estimpago(pnrecibo, vfestrec);

   IF w_num_aux <> 0 THEN
      cestado := 4;
      RETURN cestado;
   END IF;

   vpasexec := 3;

   SELECT NVL(cestaux, 0), cempres
     INTO xcestaux, w_empresa
     FROM recibos
    WHERE nrecibo = pnrecibo;

   IF xcestaux = 0
      OR xcestaux = 2
      OR xcestaux = 1 THEN   -- Vàlid (en vigor)
      vpasexec := 4;

      IF pfestrec IS NULL THEN
         SELECT a.cestrec, a.fmovini, a.ctipcob
           -- CTIPCOBRO : 0-POR CAJA, 1.- HOST, NULL.- DOMICILIADO
         INTO   cestado, v_fmovini, tipcobro
           FROM movrecibo a
          WHERE a.nrecibo = pnrecibo
            AND a.fmovfin IS NULL
            AND a.SMOVREC = (SELECT MAX(SMOVREC) FROM MOVRECIBO B WHERE B.NRECIBO = A.NRECIBO);
      ELSE
         SELECT a.cestrec, a.fmovini, a.ctipcob
           -- CTIPCOBRO : 0-POR CAJA, 1.- HOST, NULL.- DOMICILIADO
         INTO   cestado, v_fmovini, tipcobro
           FROM movrecibo a
          WHERE a.nrecibo = pnrecibo
            AND TRUNC(pfestrec) >= a.fmovini
            AND(TRUNC(pfestrec) < a.fmovfin
                OR a.fmovfin IS NULL)
                AND a.SMOVREC = (SELECT MAX(SMOVREC) FROM MOVRECIBO B WHERE B.NRECIBO = A.NRECIBO);
      END IF;

      IF NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa,'COBRADO_DIAS_GESTION'),0) <> 1 THEN
         IF cestado IS NOT NULL THEN
             -- Si el estado es cobrado, es un cobro domiciliado y la fecha es menor a una determinada
            -- en PARINSTALACION el estado será 'Gestión Cobro'
            IF tipcobro IS NULL
               AND cestado = 1 THEN
               /*BUG 0010676: 09/07/2009 : ETM -- CEM - Días de gestión de un recibo-- antes--> dias_gestion := NVL(f_parinstalacion_n('DIASGEST'), 0); */
               -- 10676.22/09/2009.NMM.i. Substituïm el paràmetre pnrecibo per w_empresa.
               -- BUG 35103-200056.KJSC . Se debe sustituir w_empresa por el número de recibo (pnrecibo).
               vpasexec := 5;
               --dias_gestion := pac_adm.f_get_diasgest(w_empresa);
               -- 10676.22/09/2009.NMM.f.

               -- BUG 35103-200056.KJSC
               dias_gestion := pac_adm.f_get_diasgest(pnrecibo);
               -- BUG 35103-200056.KJSC
               vpasexec := 6;

               IF f_sysdate <= v_fmovini + dias_gestion
                  OR v_fmovini > f_sysdate THEN
                  cestado := 3;
               ELSE
                  cestado := 1;
               END IF;
            END IF;
         END IF;
      END IF;
   END IF;

   vpasexec := 7;
   RETURN cestado;
EXCEPTION
   WHEN OTHERS THEN
      p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLCODE || ' - ' || SQLERRM);
      RETURN(NULL);
-- Error al recuperar descripció de la situació d'un rebut
END f_cestrec_mv;

/
