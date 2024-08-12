
dashboard "Author" {

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
          "[Author](${local.host}/steampipe_stats.dashboard.Author)",
          "Author"
        )
      }

    }

    container {
      width = 4
      input "author_id" {
        title = "Select Author"
        type = "select"
        sql = <<EOQ
          select
            name as label,
            id as value
          from
            wordpress_author
          order by
            name
        EOQ
      }
    }

    container {

      table "author" {
        args = [self.input.author_id.value]
        sql = <<EOQ
          select
            name,
            description,
            link
          from
            wordpress_author
          where
            id = $1
        EOQ

        column "name" {
          href = "{{.link}}"
        }

        column "description" {
          wrap = "all"
        }

      }

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


    table "author_posts" {
      args = [self.input.author_id.value]
      sql = <<EOQ
        select
          replace(title, '&#8217;', '''') as title,
          to_char(date, 'YYYY-MM-DD') as date,
          link
        from
          wordpress_post
        where
          author = $1
        order by
          date desc
      EOQ

    }


}
