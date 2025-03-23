class Blog
  attr_reader :id, :title, :content, :created_at, :updated_at, :slug

  def initialize(attributes = {})
    @id = attributes[:id]
    @title = attributes[:title]
    @content = attributes[:content]
    @created_at = attributes[:created_at] || Time.current
    @updated_at = attributes[:updated_at] || Time.current
    @slug = attributes[:slug] || @title.to_s.parameterize
  end

  def self.all
    Dir.glob(Rails.root.join('content/blogs/*.md'))
      .sort_by { |file| File.mtime(file) }
      .reverse
      .map.with_index do |file, index|
        file_content = File.read(file)
        frontmatter, content = parse_frontmatter(file_content)

        filename = File.basename(file, '.md')

        new(
          id: index + 1,
          title: frontmatter['title'] || filename.titleize,
          content: content,
          created_at: frontmatter['created_at'] ? Time.parse(frontmatter['created_at']) : File.ctime(file),
          updated_at: frontmatter['updated_at'] ? Time.parse(frontmatter['updated_at']) : File.mtime(file),
          slug: frontmatter['slug'] || filename
        )
      end
  end

  def self.find(slug)
    all.find { |blog| blog.slug == slug }
  end

  def self.find_by_id(id)
    all.find { |blog| blog.id.to_s == id.to_s }
  end

  def content_html
    renderer = Redcarpet::Render::HTML.new(hard_wrap: true, filter_html: false)
    markdown = Redcarpet::Markdown.new(renderer, autolink: true, tables: true, fenced_code_blocks: true)
    markdown.render(content)
  end

  def summary
    plain_text = ActionView::Base.full_sanitizer.sanitize(content_html)
    plain_text.truncate(160)
  end

  private

  def self.parse_frontmatter(content)
    if content =~ /\A---\s*\n(.*?)\n---\s*\n(.*)\z/m
      [YAML.safe_load($1), $2]
    else
      [{}, content]
    end
  end
end