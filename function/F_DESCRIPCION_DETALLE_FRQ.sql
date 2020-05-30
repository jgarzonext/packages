--------------------------------------------------------
--  DDL for Function F_DESCRIPCION_DETALLE_FRQ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_DESCRIPCION_DETALLE_FRQ" (p_cfranq IN NUMBER,p_nfraver IN NUMBER,p_ngrpfra IN NUMBER, p_ngrpgara IN NUMBER,p_nordfra IN NUMBER,p_cidioma IN NUMBER)
	   	  		  		   						   			 RETURN varchar2 authid current_user IS

    x_descfrq VARCHAR2(100);
	x_monint  VARCHAR2(3);
	x_texto   VARCHAR2(100);
	v_tipfra  NUMBER;
	v_ifranq  NUMBER;
	v_nrgmin  NUMBER;
	v_nrgmax  NUMBER;
	v_pfranq  NUMBER;
	v_ndfranq NUMBER;

BEGIN

	 BEGIN
	 	  SELECT ctipfra,ifranq,nrgmin,nrgmax,pfranq,ndfranq
		  		  INTO v_tipfra,v_ifranq,v_nrgmin,v_nrgmax,v_pfranq,v_ndfranq
		  FROM detfranquicias
		  WHERE CFRANQ = p_cfranq AND
			  	NFRAVER = p_nfraver AND
			  	NGRPFRA = p_ngrpfra AND
			  	NGRPGARA = p_ngrpgara AND
			  	NORDEN = p_nordfra;

		  IF v_tipfra = 1 THEN
 				-- Tipo franquicia Importe (Importe + moneda + mínimo + máximo
	 			BEGIN
		 			SELECT cmonint
		 			INTO x_monint
		 			FROM MONEDAS
		 			WHERE cidioma = p_cidioma AND cmoneda = (SELECT nvalpar FROM parinstalacion WHERE cparame='MONEDAINST');
	 			EXCEPTION
	 				WHEN OTHERS THEN
	 					NULL;
	 			END;
 				x_descfrq := v_ifranq||x_monint;

 				IF v_nrgmin IS NOT NULL THEN
 					SELECT DECODE(p_cidioma,1,'Mínim: ',2,' Mínimo: ') INTO x_texto FROM DUAL;
 					x_descfrq := x_descfrq||x_texto||v_nrgmin;
 				END IF;
 				IF v_nrgmax IS NOT NULL THEN
 					SELECT DECODE(p_cidioma,1,'Màxim: ',2,' Máximo: ') INTO x_texto FROM DUAL;
 					x_descfrq := x_descfrq||x_texto||v_nrgmax;
 				END IF;

 			ELSIF v_tipfra = 2 THEN
 				-- Tipo franquicia %DTO (Porcentaje + '%' + mínimo + máximo

 				x_descfrq := v_pfranq||'% ';
 				IF v_nrgmin IS NOT NULL THEN
 					SELECT DECODE(p_cidioma,1,'Mínim: ',2,' Mínimo: ') INTO x_texto FROM DUAL;
 					x_descfrq := x_descfrq||x_texto||v_nrgmin;
 				END IF;
 				IF v_nrgmax IS NOT NULL THEN
 					SELECT DECODE(p_cidioma,1,'Màxim: ',2,' Máximo: ') INTO x_texto FROM DUAL;
 					x_descfrq := x_descfrq||x_texto||v_nrgmax;
 				END IF;

 			ELSE
 				-- Tipo franquicia Dias (Número de dias + 'DIAS' + mínimo + máximo

 				SELECT DECODE(p_cidioma,1,'Dies: ',2,' Dias: ') INTO x_texto FROM DUAL;
 				x_descfrq := v_ndfranq||x_texto;
 				IF v_nrgmin IS NOT NULL THEN
 					SELECT DECODE(p_cidioma,1,'Mínim :',2,' Mínimo: ') INTO x_texto FROM DUAL;
 					x_descfrq := x_descfrq||x_texto||v_nrgmin;
 				END IF;
 				IF v_nrgmax IS NOT NULL THEN
 					SELECT DECODE(p_cidioma,1,'Màxim :',2,' Máximo: ') INTO x_texto FROM DUAL;
 					x_descfrq := x_descfrq||x_texto||v_nrgmax;
 				END IF;
 			END IF;
			return (x_descfrq);
		  /******/
	 EXCEPTION
	 		  WHEN OTHERS THEN
			  	   RETURN NULL;
	 END;
END;

 
 

/

  GRANT EXECUTE ON "AXIS"."F_DESCRIPCION_DETALLE_FRQ" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_DESCRIPCION_DETALLE_FRQ" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_DESCRIPCION_DETALLE_FRQ" TO "PROGRAMADORESCSI";
