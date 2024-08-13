
dashboard "Author" {

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
          "[Author](${local.host}/wordpress_stats.dashboard.Author)",
          "Author"
        )
      }

    }

    container {

      input "author_id" {
        width = 4        
        title = "Select Author"
        type = "select"
        sql = <<EOQ
          select
            name as label,
            id as value
          from
            wp_author
          order by
            name
        EOQ
      }
    }

    container {

      table "author" {
        width = 6
        args = [self.input.author_id.value]
        sql = <<EOQ
          select
            name,
            description,
            link
          from
            wp_author
          where
            id = $1
        EOQ

        column "description" {
          wrap = "all"
        }
      }


      chart "author_categories" {
        width = 6
        type = "donut"
        args = [self.input.author_id.value]
        sql = <<EOQ
          with post_categories as (
            select 
              jsonb_array_elements(category) :: int as category_id
            from 
              wordpress_post
            where 
              author = $1
          ),
          category_counts as (
            select 
              pc.category_id,
              wc.name as category_name,
              count(*) as post_count
            from 
              post_categories pc
            join 
              wordpress_category wc on pc.category_id = wc.id
            group by 
              pc.category_id, wc.name
            order by 
              post_count desc
          )
          select 
            category_name,
            post_count
          from 
            category_counts
        EOQ
            
        }

    }

    container {

      chart "author_posts" {
        title = "Posts by month"
        args = [self.input.author_id.value]
        sql = <<EOQ
          with months as (
            select date_trunc('month', series) as month
          from
            generate_series(
              '2014-01-01' :: timestamp,
              current_date,
              '1 month' :: interval
            ) as series
          ),
          posts as (
            select
              date(to_char(date(date), 'YYYY-MM') || '-01') as month,
              count(*) as posts
            from
              wordpress_post
            where
              author = $1
            group by
              month
            order by
              month
          )
          select 
            month,
            posts
          from
            months
            left join posts using (month)             
        EOQ

      }

    }


    container {

      table "author_posts" {
        args = [self.input.author_id.value]
        sql = <<EOQ
          with category_expanded as (
            select
              wp.id,
              wp.title,
              wp.date,
              wp.link,
              jsonb_array_elements_text(wp.category) as category_id
            from
              wordpress_post wp
            where
              wp.author = $1
          )
          select
            replace(ce.title, '&#8217;', '''') as title,
            to_char(ce.date, 'yyyy-mm-dd') as date,
            string_agg(distinct c.name, ', ' order by c.name) as categories,
            ce.link
          from
            category_expanded ce
          join
            wordpress_category c on c.id = ce.category_id::int
          group by
            ce.id, ce.title, ce.date, ce.link
          order by
            ce.date desc
        EOQ


      }

    }

}




