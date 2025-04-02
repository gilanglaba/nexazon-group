/*order.total_price vs payment_transaction.payment_amount*/
UPDATE payment_transaction pt
SET payment_amount = o.total_price
FROM "order" o
WHERE o.payment_transaction_id = pt.payment_transaction_id
;

--------
/*order.total_item vs order_detail.quantity (sum) per order*/
UPDATE "order" o
SET total_item = od.total_quantity
FROM (select
		order_id,
		sum(quantity) as total_quantity
		from order_detail
		group by order_id) od
WHERE o.order_id = od.order_id
;

-----------------
/*product.total_sold vs order_detail.quantity (sum) per product*/
UPDATE product p
SET total_sold = od.total_quantity
FROM (select
	product_id,
	sum(quantity) as total_quantity
	from order_detail
	where order_id in (select order_id from "order" where order_status not in ('Pending Payment','Returned'))
	group by product_id) od
WHERE p.product_id = od.product_id
;

update product set total_sold = 0
where product_id not in (select 
	p.product_id
	from product p
		inner join (
		select
		product_id,
		sum(quantity) as total_quantity
		from order_detail
		where order_id in (select order_id from "order" where order_status not in ('Pending Payment','Returned'))
		group by product_id
		) od
		on p.product_id = od.product_id
		);