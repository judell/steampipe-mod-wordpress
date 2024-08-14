dashboard "Authors" {

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
          "[Authors](${local.host}/wordpress_stats.dashboard.Authors)",
          "Authors"
        )
      }

    }


    table "authors" {
      sql = <<EOQ
        select
          name,
          description,
          link,
          id
        from
          wordpress_author
        order by name
      EOQ

      column "name" {
        href = "${local.host}/wordpress_stats.dashboard.Author?input.author_id={{.id}}"
      }      

      column "description" {
        wrap = "all"
      }


    }

}
