/*
018 ASSIGNMENT Analyzing Product Refund Rates - 
MrFuzzy supplier had some quality issues which were’s corrected until Sep 2013 then they had a major problem where the bears arms were falling off in Aug/Sep 2014. 
As a result, we replaced them with a new supplier on Sep 14 2014. 
Pull monthly product refund rates by product and confirm the quality issues are now fixed 
*/

SELECT 
	YEAR(order_items.created_at) AS yr,
    MONTH(order_items.created_at) AS mo,
    COUNT(DISTINCT CASE WHEN order_items.product_id = 1 THEN order_items.order_item_id ELSE NULL END) AS p1_orders,
    
	COUNT(DISTINCT CASE WHEN order_items.product_id = 1 THEN order_item_refunds.order_item_id ELSE NULL END)/
    COUNT(DISTINCT CASE WHEN order_items.product_id = 1 THEN order_items.order_item_id ELSE NULL END) AS p1_refund_rate,
    
	COUNT(DISTINCT CASE WHEN order_items.product_id = 2 THEN order_items.order_item_id ELSE NULL END) AS p2_orders,

 	COUNT(DISTINCT CASE WHEN order_items.product_id = 2 THEN order_item_refunds.order_item_id ELSE NULL END)/
    COUNT(DISTINCT CASE WHEN order_items.product_id = 2 THEN order_items.order_item_id ELSE NULL END) AS p2_refund_rate,   
    
	COUNT(DISTINCT CASE WHEN order_items.product_id = 3 THEN order_items.order_item_id ELSE NULL END) AS p3_orders,

 	COUNT(DISTINCT CASE WHEN order_items.product_id = 3 THEN order_item_refunds.order_item_id ELSE NULL END)/
    COUNT(DISTINCT CASE WHEN order_items.product_id = 3 THEN order_items.order_item_id ELSE NULL END) AS p3_refund_rate,      
    
    
	COUNT(DISTINCT CASE WHEN order_items.product_id = 4 THEN order_items.order_item_id ELSE NULL END) AS p4_orders,

 	COUNT(DISTINCT CASE WHEN order_items.product_id = 4 THEN order_item_refunds.order_item_id ELSE NULL END)/
    COUNT(DISTINCT CASE WHEN order_items.product_id = 4 THEN order_items.order_item_id ELSE NULL END) AS p4_refund_rate
    
FROM order_items LEFT JOIN order_item_refunds ON order_items.order_id = order_item_refunds.order_id
WHERE order_items.created_at < '2014-10-15'
GROUP BY 1,2