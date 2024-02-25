SELECT
	order_items.order_id,
    order_items.order_item_id,
    order_items.price_usd,
    order_items.created_at,
    order_item_refunds.order_item_refund_id,
    order_item_refunds.refund_amount_usd,
    order_item_refunds.created_at
FROM order_items LEFT JOIN order_item_refunds ON order_item_refunds.order_item_id = order_items.order_item_id
WHERE order_items.order_id IN (3489,32049,27061)