
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
      input "author_id" {
        title = "Select Author"
        width = 4
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
        width = 6
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
        width = 6
        args = [self.input.author_id.value]
        sql = <<EOQ
          select
            to_char(date, 'YYYY-MM') as month,
            count(*)
          from
            wordpress_post
          where
            author = $1
          group by
            month
          order by
            month
        EOQ

      }


    }


    table "author_posts" {
      args = [self.input.author_id.value]
      sql = <<EOQ
        select
          title, 
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
