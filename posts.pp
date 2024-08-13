dashboard "RecentPosts" {

    tags = {
      service = "WordPress Stats"
    }


    container {
      
      text {
        width = 8
        value = replace(
          replace(
            "${local.menu}",
            "__HOST__",
            "${local.host}"
          ),
          "[RecentPosts](${local.host}/steampipe_stats.dashboard.RecentPosts)",
          "RecentPosts"
        )
      }

    }


    table "posts" {
      sql = <<EOQ
        with posts as materialized (
          select
            p.id,
            p.title,
            p.author,
            p.link,
            jsonb_array_elements_text(p.category) as category_id,  -- Convert category JSONB array elements to text
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
            a.id as author_id,
            p.day,
            c.name as category
          from
            posts p
          join
            wp_author a on p.author = a.id
          join
            wordpress_category c on c.id = p.category_id::int  -- Direct join instead of subquery
        )
        select
          replace(nc.title, '&#8217;', '''') as title,
          nc.name,
          nc.day,
          string_agg(distinct nc.category, ', ' order by nc.category) as categories,  -- Aggregate distinct categories
          nc.link,
          nc.author_id
        from
          named_categories nc
        group by
          nc.id, nc.title, nc.link, nc.name, nc.day, nc.author_id
        order by
          nc.day desc, nc.name;
      EOQ

      column "title" {
        href = "{{.link}}"
      }

      column "name" {
        href = "${local.host}/wordpress_stats.dashboard.Author?input.author_id={{.author_id}}"
      }      


    }

}
