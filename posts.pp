dashboard "recent_posts" {

    table "posts" {
      sql = <<EOQ
        with posts as materialized (
          select
            p.id,
            p.title,
            p.author,
            p.link,
            jsonb_array_elements(p.category) as category_id,
            to_char(p.date, 'YYYY-MM-DD') as day
          from
            wordpress_post p
          where
            p.date > now() - interval '7 day'
          order by
            p.date desc
        ),
        named_categories as (
          select
            p.id,
            p.title,
            p.link,
            a.name,
            p.day,
            (select name from wordpress_category c where c.id = p.category_id::int) as category
          from
            posts p
          join
            wordpress_author a
          on
            p.author = a.id
        )
        select
            nc.title,
            nc.name,
            nc.day,
            string_agg(nc.category, ', ' order by nc.category) as categories,
            nc.link

        from
          named_categories nc
        group by
          nc.id, nc.title, nc.link, nc.name, nc.day
        order by
          nc.day desc, nc.name
      EOQ

      column "title" {
        href = "{{.link}}"
      }
    }

}
