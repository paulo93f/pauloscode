class BlogsController < ApplicationController
  allow_unauthenticated_access only: %i[index show destroy]

  def index
    @blogs = Blog.all
  end

  def show
    @blog = Blog.find(params[:id])

    if @blog.nil?
      redirect_to blogs_path, alert: "Blog no encontrado"
    end
  end

  def new
    @blog = Blog.new
  end

  def create
    title = params[:blog][:title].presence || "Sin título"
    content = params[:blog][:content]
    slug = title.parameterize

    created_at = Time.current.strftime('%Y-%m-%dT%H:%M:%SZ')

    # Handle image upload
    image_path = nil
    if params[:blog][:image].present?
      image = params[:blog][:image]
      if image.respond_to?(:original_filename)
        filename = "#{slug}-#{Time.current.to_i}#{File.extname(image.original_filename)}"
        image_path = "/images/blogs/#{filename}"
        
        # Save the file
        File.open(Rails.root.join('public', image_path), 'wb') do |file|
          file.write(image.read)
        end
      else
        image_path = image
      end
    end

    # Creamos el frontmatter
    frontmatter = {
      'title' => title,
      'created_at' => created_at,
      'updated_at' => created_at,
      'slug' => slug,
      'image' => image_path
    }

    # Creamos el contenido del archivo
    file_content = "---\n#{frontmatter.to_yaml}---\n\n#{content}"

    # Guardamos el archivo
    file_path = Rails.root.join("content/blogs/#{slug}.md")

    begin
      File.write(file_path, file_content)
      redirect_to blog_path(slug), notice: "Blog creado exitosamente"
    rescue => e
      flash.now[:alert] = "Error al guardar el blog: #{e.message}"
      render :new
    end
  end

  def edit
    @blog = Blog.find(params[:id])

    if @blog.nil?
      redirect_to blogs_path, alert: "Blog no encontrado"
    end
  end

  def update
    @blog = Blog.find(params[:id])

    if @blog.nil?
      redirect_to blogs_path, alert: "Blog no encontrado"
      return
    end

    title = params[:blog][:title].presence || @blog.title
    content = params[:blog][:content]
    slug = title.parameterize

    # Handle image upload
    image_path = @blog.image
    if params[:blog][:image].present?
      image = params[:blog][:image]
      if image.respond_to?(:original_filename)
        # Delete old image if exists
        if @blog.image.present?
          old_image_path = Rails.root.join('public', @blog.image)
          File.delete(old_image_path) if File.exist?(old_image_path)
        end

        filename = "#{slug}-#{Time.current.to_i}#{File.extname(image.original_filename)}"
        image_path = "/images/blogs/#{filename}"
        
        # Save the file
        File.open(Rails.root.join('public', image_path), 'wb') do |file|
          file.write(image.read)
        end
      else
        image_path = image
      end
    end

    # Actualizamos el frontmatter
    frontmatter = {
      'title' => title,
      'created_at' => @blog.created_at.strftime('%Y-%m-%dT%H:%M:%SZ'),
      'updated_at' => Time.current.strftime('%Y-%m-%dT%H:%M:%SZ'),
      'slug' => slug,
      'image' => image_path
    }

    # Creamos el contenido del archivo
    file_content = "---\n#{frontmatter.to_yaml}---\n\n#{content}"

    # Actualizamos el archivo actual
    current_file_path = Rails.root.join("content/blogs/#{@blog.slug}.md")
    new_file_path = Rails.root.join("content/blogs/#{slug}.md")

    begin
      # Si cambió el slug, eliminar el archivo antiguo
      if @blog.slug != slug && File.exist?(current_file_path)
        File.delete(current_file_path)
      end

      # Escribir el nuevo archivo
      File.write(new_file_path, file_content)

      redirect_to blog_path(slug), notice: "Blog actualizado exitosamente"
    rescue => e
      flash.now[:alert] = "Error al actualizar el blog: #{e.message}"
      render :edit
    end
  end

  def destroy
    @blog = Blog.find(params[:id])

    if @blog.nil?
      redirect_to blogs_path, alert: "Blog no encontrado"
      return
    end

    file_path = Rails.root.join("content/blogs/#{@blog.slug}.md")

    begin
      if File.exist?(file_path)
        File.delete(file_path)
        redirect_to blogs_path, notice: "Blog eliminado exitosamente"
      else
        redirect_to blogs_path, alert: "El archivo del blog no fue encontrado"
      end
    rescue => e
      redirect_to blogs_path, alert: "Error al eliminar el blog: #{e.message}"
    end
  end
end