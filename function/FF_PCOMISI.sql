--------------------------------------------------------
--  DDL for Function FF_PCOMISI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."FF_PCOMISI" (
   pnsesion IN NUMBER,
   psseguro IN NUMBER,
   pcmodcom IN NUMBER,
   pfretenc IN DATE,
   pcagente IN NUMBER DEFAULT NULL,
   pcramo IN NUMBER DEFAULT NULL,
   pcmodali IN NUMBER DEFAULT NULL,
   pctipseg IN NUMBER DEFAULT NULL,
   pccolect IN NUMBER DEFAULT NULL,
   pcactivi IN NUMBER DEFAULT NULL,
   pcgarant IN NUMBER DEFAULT NULL,
   pttabla IN VARCHAR2 DEFAULT NULL,
   pfuncion IN VARCHAR2 DEFAULT 'CAR',
   pfecha IN DATE DEFAULT f_sysdate,
   pnanuali IN NUMBER DEFAULT NULL,
   pccomind IN NUMBER DEFAULT 0)
   RETURN NUMBER IS
   /******************************************************************************
      NOMBRE:     FF_PCOMISI
      PROPÓSITO:  Función que devuelve la comisión dependiendo de los parametros de
                  entrada informados(por el producto o por el sseguro)

      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
      1.0        22/05/2012  DRA              0020054: MDPXXX - TEC - Producto de Edificios Nueva Producción (2001) - Parametrización inicial
   ******************************************************************************/
   num_err        NUMBER := 0;
   xpcomisi       NUMBER := 0;
   xpretenc       NUMBER := 0;
   vpasexec       NUMBER(8) := 1;
   vparam         VARCHAR2(2000)
      := 'pnsesion  : ' || pnsesion || ' - psseguro  : ' || psseguro || ' - pcmodcom  : '
         || pcmodcom || ' - pfretenc  : ' || TO_CHAR(pfretenc, 'dd/mm/yyyy')
         || ' - pcagente  : ' || pcagente || ' - pcramo  : ' || pcramo || ' - pcmodali  : '
         || pcmodali || ' - pctipseg  : ' || pctipseg || ' - pccolect  : ' || pccolect
         || ' - pcactivi  : ' || pcactivi || ' - pcgarant  : ' || pcgarant || ' - pttabla  : '
         || pttabla || ' - pfuncion  : ' || pfuncion || ' - pfecha  : '
         || TO_CHAR(pfecha, 'dd/mm/yyyy') || ' - pnanuali : ' || pnanuali;
   error_com      EXCEPTION;
BEGIN
   vpasexec := 1;
   num_err := f_pcomisi(psseguro, pcmodcom, pfretenc, xpcomisi, xpretenc, pcagente, pcramo,
                        pcmodali, pctipseg, pccolect, pcactivi, pcgarant, pttabla, pfuncion,
                        pfecha, pnanuali, pccomind);

   IF num_err <> 0 THEN
      RAISE error_com;
   END IF;

   RETURN xpcomisi;
EXCEPTION
   WHEN error_com THEN
      p_tab_error(f_sysdate, f_user, 'ff_pcomisi', vpasexec, vparam,
                  f_axis_literales(num_err));
      RETURN NULL;
   WHEN OTHERS THEN
      p_tab_error(f_sysdate, f_user, 'ff_pcomisi', vpasexec, vparam, SQLERRM);
      RETURN NULL;
END ff_pcomisi;

/

  GRANT EXECUTE ON "AXIS"."FF_PCOMISI" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."FF_PCOMISI" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."FF_PCOMISI" TO "PROGRAMADORESCSI";
