dashboard "Category" {

    tags = {
      service = "WordPress Stats"
    }


    container {
      
      text {
        width = 4
        value = replace(
          replace(
            "${local.menu}",
            "__HOST__",
            "${local.host}"
          ),
          "[Category](${local.host}/wordpress_stats.dashboard.Category)",
          "Category"
        )
      }

    }


    container {

      input "category_id" {
        width = 4        
        title = "Select Category"
        type = "select"
        sql = <<EOQ
          select
            name as label,
            id as value
          from
            wordpress_category
          order by
            name
        EOQ
      }
    }

    container {

      table "category_posts" {
        args = [self.input.category_id.value]
        title = "Recent posts in category"
        sql = <<EOQ
          with posts as materialized (
            select
              p.id,
              p.title,
              p.author,
              p.link,
              jsonb_array_elements_text(p.category) as category_id,
              to_char(p.date, 'YYYY-MM-DD') as day
            from
              wordpress_post p
            where
              $1 = ANY(array(select jsonb_array_elements_text(p.category)))
              and p.date > now() - interval '1 month'
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
              wordpress_author a on p.author = a.id
            join
              wordpress_category c on c.id = p.category_id::int
          )
          select
            replace(nc.title, '&#8217;', '''') as title,
            nc.name,
            nc.day,
            string_agg(distinct nc.category, ', ' order by nc.category) as categories,
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



}    